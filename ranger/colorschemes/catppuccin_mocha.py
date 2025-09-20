# Catppuccin Mocha colorscheme for ranger
# Based on the Catppuccin Mocha color palette

from ranger.gui.colorscheme import ColorScheme
from ranger.gui.color import *

class CatppuccinMocha(ColorScheme):
    progress_bar_color = 117  # Lavender

    def use(self, context):
        fg, bg, attr = default_colors

        if context.reset:
            return default_colors

        elif context.in_browser:
            if context.selected:
                attr = reverse
            else:
                attr = normal
            if context.empty or context.error:
                fg = 203  # Red
            if context.border:
                fg = 186  # Surface2
            if context.media:
                if context.image:
                    fg = 222  # Yellow
                else:
                    fg = 219  # Pink
            if context.container:
                fg = 203  # Red
            if context.directory:
                attr |= bold
                fg = 116  # Blue
            elif context.executable and not \
                    any((context.media, context.container,
                        context.fifo, context.socket)):
                attr |= bold
                fg = 151  # Green
            if context.socket:
                fg = 219  # Pink
                attr |= bold
            if context.fifo or context.device:
                fg = 222  # Yellow
                if context.device:
                    attr |= bold
            if context.link:
                fg = context.good and 159 or 219  # Teal or Pink
            if context.bad:
                bg = 203  # Red
            if context.tag_marker and not context.selected:
                attr |= bold
                if fg in (203, 219):  # Red, Pink
                    fg = 205  # Text
                else:
                    fg = 203  # Red
            if not context.selected and (context.cut or context.copied):
                fg = 237  # Base
                attr |= bold
            if context.main_column:
                if context.selected:
                    attr |= bold
                if context.marked:
                    attr |= bold
                    fg = 222  # Yellow
            if context.badinfo:
                if attr & reverse:
                    bg = 203  # Red
                else:
                    fg = 203  # Red

        elif context.in_titlebar:
            attr |= bold
            if context.hostname:
                fg = context.bad and 203 or 151  # Red or Green
            elif context.directory:
                fg = 116  # Blue
            elif context.tab:
                if context.good:
                    bg = 151  # Green
            elif context.link:
                fg = 159  # Teal

        elif context.in_statusbar:
            if context.permissions:
                if context.good:
                    fg = 159  # Teal
                elif context.bad:
                    fg = 203  # Red
            if context.marked:
                attr |= bold | reverse
                fg = 222  # Yellow
            if context.message:
                if context.bad:
                    attr |= bold
                    fg = 203  # Red
            if context.loaded:
                bg = self.progress_bar_color
            if context.vcsinfo:
                fg = 116  # Blue
                attr &= ~bold
            if context.vcscommit:
                fg = 222  # Yellow
                attr &= ~bold

        if context.text:
            if context.highlight:
                attr |= reverse

        if context.in_taskview:
            if context.title:
                fg = 116  # Blue

            if context.selected:
                attr |= reverse

            if context.loaded:
                if context.selected:
                    fg = self.progress_bar_color
                else:
                    bg = self.progress_bar_color

        if context.vcsfile and not context.selected:
            attr &= ~bold
            if context.vcsconflicts:
                fg = 219  # Pink
            elif context.vcschanged:
                fg = 203  # Red
            elif context.vcsunknown:
                fg = 203  # Red
            elif context.vcsstaged:
                fg = 151  # Green
            elif context.vcssync:
                fg = 151  # Green
            elif context.vcsignored:
                fg = 186  # Surface2

        elif context.vcsremote and not context.selected:
            attr &= ~bold
            if context.vcssync:
                fg = 151  # Green
            elif context.vcsbehind:
                fg = 203  # Red
            elif context.vcsahead:
                fg = 116  # Blue
            elif context.vcsdiverged:
                fg = 219  # Pink
            elif context.vcsunknown:
                fg = 203  # Red

        return fg, bg, attr