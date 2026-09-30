-- programs.lua - Program definitions and mainMod
-- From programs.conf.bak:7-12 and keybinds.conf.bak:6
-- Globals exposed for keybinds.lua
terminal    = "kitty"
fileManager = "thunar"
menu        = "pgrep -x wofi >/dev/null || wofi --show drun --prompt 'Program Launcher'"
browser     = 'brave --ozone-platform=wayland --enable-features=UseOzonePlatform --password-store=basic --profile-directory="Default"'
discord     = "discord"
spotify     = "spotify-launcher"

mainMod = "SUPER" -- Sets "Windows" key as main modifier
