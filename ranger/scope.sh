#!/usr/bin/env bash

set -o noclobber -o noglob -o nounset -o pipefail
IFS=$'\n'

## Script arguments
FILE_PATH="${1}"         # Full path of the highlighted file
PV_WIDTH="${2}"          # Width of the preview pane (number of fitting characters)
PV_HEIGHT="${3}"         # Height of the preview pane (number of fitting characters)
IMAGE_CACHE_PATH="${4}"  # Full path that should be used to cache image preview
PV_IMAGE_ENABLED="${5}"  # 'True' if image previews are enabled, 'False' otherwise.

FILE_EXTENSION="${FILE_PATH##*.}"
FILE_EXTENSION_LOWER="$(printf "%s" "${FILE_EXTENSION}" | tr '[:upper:]' '[:lower:]')"

## Settings
HIGHLIGHT_SIZE_MAX=262143  # 256KiB
HIGHLIGHT_TABWIDTH=${HIGHLIGHT_TABWIDTH:-8}
HIGHLIGHT_STYLE=${HIGHLIGHT_STYLE:-pablo}
PYGMENTIZE_STYLE=${PYGMENTIZE_STYLE:-autumn}

handle_extension() {
    case "${FILE_EXTENSION_LOWER}" in
        ## Archive
        a|ace|alz|arc|arj|bz|bz2|cab|cpio|deb|gz|jar|lha|lz|lzh|lzma|lzo|\
        rpm|rz|t7z|tar|tbz|tbz2|tgz|tlz|txz|tZ|tzo|war|xpi|xz|Z|zip)
            atool --list -- "${FILE_PATH}" && exit 5
            bsdtar --list --file "${FILE_PATH}" && exit 5
            exit 1;;
        rar)
            ## Avoid password prompt by providing empty password
            unrar lt -p- -- "${FILE_PATH}" && exit 5
            exit 1;;
        7z)
            ## Avoid password prompt by providing empty password
            7z l -p -- "${FILE_PATH}" && exit 5
            exit 1;;

        ## PDF
        pdf)
            ## Preview as text conversion
            pdftotext -l 10 -nopgbrk -q -- "${FILE_PATH}" - 2>/dev/null | \
                head -n $((PV_HEIGHT-2)) | fmt -w $((PV_WIDTH-2)) && exit 5
            mutool draw -F txt -i -- "${FILE_PATH}" 1-10 2>/dev/null | \
                head -n $((PV_HEIGHT-2)) | fmt -w $((PV_WIDTH-2)) && exit 5
            exiftool "${FILE_PATH}" && exit 5
            exit 1;;

        ## BitTorrent
        torrent)
            transmission-show -- "${FILE_PATH}" && exit 5
            exit 1;;

        ## OpenDocument
        odt|ods|odp|sxw)
            ## Preview as text conversion
            odt2txt "${FILE_PATH}" && exit 5
            ## Preview as markdown conversion
            pandoc -s -t markdown -- "${FILE_PATH}" && exit 5
            exit 1;;

        ## XLSX
        xlsx)
            ## Preview as csv conversion
            ## Uses: https://github.com/dilshod/xlsx2csv
            xlsx2csv -- "${FILE_PATH}" && exit 5
            exit 1;;

        ## HTML
        htm|html|xhtml)
            ## Preview as text conversion
            w3m -dump "${FILE_PATH}" && exit 5
            lynx -dump -- "${FILE_PATH}" && exit 5
            elinks -dump "${FILE_PATH}" && exit 5
            pandoc -s -t markdown -- "${FILE_PATH}" && exit 5
            ;;

        ## JSON
        json)
            jq --color-output . "${FILE_PATH}" && exit 5
            python -m json.tool -- "${FILE_PATH}" && exit 5
            ;;

        ## Direct Stream Digital/Transfer (DSDIFF) and wavpack aren't detected
        ## by file(1).
        dff|dsf|wv|wvc)
            mediainfo "${FILE_PATH}" && exit 5
            exiftool "${FILE_PATH}" && exit 5
            ;; # Continue with next handler on failure
    esac
}

handle_image() {
    ## Size of the preview if there are multiple options or it has to be
    ## rendered from vector graphics.
    local DEFAULT_SIZE="1920x1080"

    local mimetype="${1}"
    case "${mimetype}" in
        ## SVG
        image/svg+xml|image/svg)
            convert -- "${FILE_PATH}" "${IMAGE_CACHE_PATH}" && exit 6
            exit 1;;

        ## DjVu
        image/vnd.djvu)
            ddjvu -format=tiff -quality=90 -page=1 -size="${DEFAULT_SIZE}" \
                  - "${IMAGE_CACHE_PATH}" < "${FILE_PATH}" \
                  && exit 6 || exit 1;;

        ## Image - Enhanced for kitty terminal
        image/*)
            # Check if we're in kitty terminal and image preview is enabled
            if [[ "$TERM" == "xterm-kitty" ]] && [[ "$PV_IMAGE_ENABLED" == 'True' ]]; then
                # Use kitty's image display protocol for direct display
                kitty +kitten icat --clear --transfer-mode=memory --stdin=no \
                    --place="${PV_WIDTH}x${PV_HEIGHT}@0x0" "${FILE_PATH}" 2>/dev/null && exit 7
            fi
            
            # Handle image orientation
            local orientation
            orientation="$(identify -format '%[EXIF:Orientation]\n' -- "${FILE_PATH}" 2>/dev/null)"
            if [[ -n "$orientation" && "$orientation" != 1 ]]; then
                convert -- "${FILE_PATH}" -auto-orient "${IMAGE_CACHE_PATH}" && exit 6
            fi

            # Copy image to cache for display
            cp "${FILE_PATH}" "${IMAGE_CACHE_PATH}" 2>/dev/null && exit 6
            exit 7;;

        ## Video
        video/*)
            # Thumbnail
            ffmpegthumbnailer -i "${FILE_PATH}" -o "${IMAGE_CACHE_PATH}" -s 0 2>/dev/null && exit 6
            exit 1;;

        ## PDF - Enhanced PDF preview
        application/pdf)
            # Try mutool first (best quality)
            if command -v mutool >/dev/null 2>&1; then
                mutool draw -F png -r 150 -o "${IMAGE_CACHE_PATH}" "${FILE_PATH}" 1 2>/dev/null && exit 6
            fi
            
            # Try pdftoppm (good quality)
            if command -v pdftoppm >/dev/null 2>&1; then
                pdftoppm -f 1 -l 1 -scale-to-x 1200 -scale-to-y -1 -singlefile -png \
                    -- "${FILE_PATH}" "${IMAGE_CACHE_PATH%.*}" 2>/dev/null && exit 6
            fi
            
            # Try pdfimages as fallback
            if command -v pdfimages >/dev/null 2>&1; then
                pdfimages -f 1 -l 1 -png "${FILE_PATH}" "${IMAGE_CACHE_PATH%.*}" 2>/dev/null
                if [ -f "${IMAGE_CACHE_PATH%.*}"-000.png ]; then
                    mv "${IMAGE_CACHE_PATH%.*}"-000.png "${IMAGE_CACHE_PATH}" && exit 6
                fi
            fi
            exit 1;;

        ## ePub, MOBI, FB2 (using Calibre)
        application/epub+zip|application/x-mobipocket-ebook|application/x-fictionbook+xml)
            if command -v ebook-meta >/dev/null 2>&1; then
                ebook-meta --get-cover="${IMAGE_CACHE_PATH}" -- "${FILE_PATH}" >/dev/null 2>&1 && exit 6
            fi
            exit 1;;
    esac
}

handle_mime() {
    local mimetype="${1}"
    case "${mimetype}" in
        ## RTF and DOC
        text/rtf|*msword)
            ## Preview as text conversion
            ## note: catdoc does not always work for .doc files
            ## catdoc: http://www.wagner.pp.ru/~vitus/software/catdoc/
            catdoc -- "${FILE_PATH}" && exit 5
            exit 1;;

        ## DOCX, ePub, FB2 (using markdown for better formatting)
        *wordprocessingml.document|*/epub+zip|*/x-fictionbook+xml)
            ## Preview as markdown conversion
            pandoc -s -t markdown -- "${FILE_PATH}" 2>/dev/null && exit 5
            exit 1;;

        ## XLS
        *ms-excel)
            ## Preview as csv conversion
            ## xls2csv comes with catdoc:
            ##   http://www.wagner.pp.ru/~vitus/software/catdoc/
            xls2csv -- "${FILE_PATH}" && exit 5
            exit 1;;

        ## Text
        text/* | */xml)
            ## Syntax highlight
            if [[ "$( stat --printf='%s' -- "${FILE_PATH}" )" -gt "${HIGHLIGHT_SIZE_MAX}" ]]; then
                exit 2
            fi
            if [[ "$( tput colors )" -ge 256 ]]; then
                local pygmentize_format='terminal256'
                local highlight_format='xterm256'
            else
                local pygmentize_format='terminal'
                local highlight_format='ansi'
            fi
            env HIGHLIGHT_OPTIONS="${highlight_format}" \
                highlight --out-format="${highlight_format}" --force -- "${FILE_PATH}" && exit 5
            env COLORTERM=8bit bat --color=always --style="changes" \
                --wrap=never -- "${FILE_PATH}" && exit 5
            pygmentize -f "${pygmentize_format}" -O "style=${PYGMENTIZE_STYLE}"\
                -- "${FILE_PATH}" && exit 5
            exit 2;;

        ## DjVu
        image/vnd.djvu)
            ## Preview as text
            djvutxt "${FILE_PATH}" | head -n $((PV_HEIGHT-2)) | fmt -w $((PV_WIDTH-2)) && exit 5
            exiftool "${FILE_PATH}" && exit 5
            exit 1;;

        ## Image
        image/*)
            ## Preview as text
            img2txt --gamma=0.6 --width="${PV_WIDTH}" -- "${FILE_PATH}" && exit 4
            exiftool "${FILE_PATH}" && exit 5
            exit 1;;

        ## Video and audio
        video/* | audio/*)
            mediainfo "${FILE_PATH}" && exit 5
            exiftool "${FILE_PATH}" && exit 5
            exit 1;;
    esac
}

handle_fallback() {
    echo '----- File Type Classification -----' && file --dereference --brief -- "${FILE_PATH}" && exit 5
    exit 1
}

MIMETYPE="$( file --dereference --brief --mime-type -- "${FILE_PATH}" )"
if [[ "${PV_IMAGE_ENABLED}" == 'True' ]]; then
    handle_image "${MIMETYPE}"
fi
handle_extension
handle_mime "${MIMETYPE}"
handle_fallback

exit 1