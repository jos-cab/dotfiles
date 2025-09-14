# Default catppuccin theme for ranger
# You can customize this file according to your preferences

from ranger.gui.colorscheme import ColorScheme
from ranger.gui.color import *

class Catppuccin(ColorScheme):
    progress_bar_color = 12

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
                bg = 1
                fg = 15
            if context.border:
                fg = 8
            if context.document:
                fg = 13
            if context.media:
                if context.image:
                    fg = 3
                elif context.video:
                    fg = 5
                elif context.audio:
                    fg = 6
                else:
                    fg = 10
            if context.container:
                fg = 4
            if context.directory:
                fg = 4
            elif context.executable and not \
                    any(target.is_directory for target in context.targets):
                fg = 2
            if context.socket:
                fg = 5
                attr |= bold
            if context.fifo or context.device:
                fg = 3
                if context.device:
                    attr |= bold
            if context.link:
                fg = 6 if context.good else 1
            if context.tag_marker and not context.selected:
                attr |= bold
                if fg in (7, 8):
                    fg = 1
            if not context.selected and (context.cut or context.copied):
                fg = 8
                attr |= bold
            if context.main_column:
                if context.marked:
                    attr |= bold
                if context.selected:
                    attr |= reverse
            if context.badinfo:
                if attr & reverse:
                    bg = 5
                else:
                    fg = 5

        elif context.in_titlebar:
            if context.hostname:
                fg = 1 if context.bad else 2
            elif context.directory:
                fg = 4
            elif context.tab:
                if context.good:
                    bg = 2
            elif context.link:
                fg = 6

        elif context.in_statusbar:
            if context.permissions:
                if context.good:
                    fg = 2
                elif context.bad:
                    fg = 1
            if context.marked:
                attr |= bold | reverse
                fg = 8
            if context.frozen:
                attr |= bold | reverse
                fg = 6
            if context.message:
                if context.bad:
                    attr |= bold
                    fg = 1
            if context.loaded:
                bg = self.progress_bar_color
            if context.vcsinfo:
                fg = 4
                attr &= ~bold
            if context.vcscommit:
                fg = 3
                attr &= ~bold
            if context.vcsdate:
                fg = 6
                attr &= ~bold

        if context.text:
            if context.highlight:
                attr |= reverse

        if context.in_taskview:
            if context.title:
                fg = 4

            if context.selected:
                attr |= reverse

            if context.loaded:
                if context.selected:
                    fg = self.progress_bar_color
                else:
                    bg = self.progress_bar_color

        if context.vcsfile and not context.selected:
            attr &= ~bold
            if context.vcsconflict:
                fg = 1
            elif context.vcschanged:
                fg = 5
            elif context.vcsunknown:
                fg = 1
            elif context.vcsstaged:
                fg = 2
            elif context.vcssync:
                fg = 4
            elif context.vcsignored:
                fg = 8

        elif context.vcsremote and not context.selected:
            attr &= ~bold
            if context.vcssync or context.vcsnone:
                fg = 4
            elif context.vcsunknown:
                fg = 1

        return fg, bg, attr