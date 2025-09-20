# Catppuccin Mocha colorscheme for ranger
# Based on the Catppuccin Mocha color palette

from ranger.gui.colorscheme import ColorScheme
from ranger.gui.color import *

class CatppuccinMocha(ColorScheme):
    progress_bar_color = 4  # Blue (#89b4fa)

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
                fg = 1  # Red (#f38ba8)
            if context.border:
                fg = 8  # Surface2 (#585b70)
            if context.media:
                if context.image:
                    fg = 3  # Yellow (#f9e2af)
                else:
                    fg = 5  # Pink (#f5c2e7)
            if context.container:
                fg = 1  # Red (#f38ba8)
            if context.directory:
                attr |= bold
                fg = 4  # Blue (#89b4fa)
            elif context.executable and not \
                    any((context.media, context.container,
                        context.fifo, context.socket)):
                attr |= bold
                fg = 2  # Green (#a6e3a1)
            if context.socket:
                fg = 5  # Pink (#f5c2e7)
                attr |= bold
            if context.fifo or context.device:
                fg = 3  # Yellow (#f9e2af)
                if context.device:
                    attr |= bold
            if context.link:
                fg = context.good and 6 or 5  # Teal (#94e2d5) or Pink (#f5c2e7)
            if context.bad:
                bg = 1  # Red (#f38ba8)
            if context.tag_marker and not context.selected:
                attr |= bold
                if fg in (1, 5):  # Red, Pink
                    fg = 15  # Text (#a6adc8)
                else:
                    fg = 1  # Red (#f38ba8)
            if not context.selected and (context.cut or context.copied):
                fg = 0  # Surface0 (#45475a)
                attr |= bold
            if context.main_column:
                if context.selected:
                    attr |= bold
                if context.marked:
                    attr |= bold
                    fg = 3  # Yellow (#f9e2af)
            if context.badinfo:
                if attr & reverse:
                    bg = 1  # Red (#f38ba8)
                else:
                    fg = 1  # Red (#f38ba8)

        elif context.in_titlebar:
            attr |= bold
            if context.hostname:
                fg = context.bad and 1 or 2  # Red (#f38ba8) or Green (#a6e3a1)
            elif context.directory:
                fg = 4  # Blue (#89b4fa)
            elif context.tab:
                if context.good:
                    bg = 2  # Green (#a6e3a1)
            elif context.link:
                fg = 6  # Teal (#94e2d5)

        elif context.in_statusbar:
            if context.permissions:
                if context.good:
                    fg = 6  # Teal (#94e2d5)
                elif context.bad:
                    fg = 1  # Red (#f38ba8)
            if context.marked:
                attr |= bold | reverse
                fg = 3  # Yellow (#f9e2af)
            if context.message:
                if context.bad:
                    attr |= bold
                    fg = 1  # Red (#f38ba8)
            if context.loaded:
                bg = self.progress_bar_color
            if context.vcsinfo:
                fg = 4  # Blue (#89b4fa)
                attr &= ~bold
            if context.vcscommit:
                fg = 3  # Yellow (#f9e2af)
                attr &= ~bold

        if context.text:
            if context.highlight:
                attr |= reverse

        if context.in_taskview:
            if context.title:
                fg = 4  # Blue (#89b4fa)

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
                fg = 5  # Pink (#f5c2e7)
            elif context.vcschanged:
                fg = 1  # Red (#f38ba8)
            elif context.vcsunknown:
                fg = 1  # Red (#f38ba8)
            elif context.vcsstaged:
                fg = 2  # Green (#a6e3a1)
            elif context.vcssync:
                fg = 2  # Green (#a6e3a1)
            elif context.vcsignored:
                fg = 8  # Surface2 (#585b70)

        elif context.vcsremote and not context.selected:
            attr &= ~bold
            if context.vcssync:
                fg = 2  # Green (#a6e3a1)
            elif context.vcsbehind:
                fg = 1  # Red (#f38ba8)
            elif context.vcsahead:
                fg = 4  # Blue (#89b4fa)
            elif context.vcsdiverged:
                fg = 5  # Pink (#f5c2e7)
            elif context.vcsunknown:
                fg = 1  # Red (#f38ba8)

        return fg, bg, attr