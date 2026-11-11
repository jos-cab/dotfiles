-- autostart.lua - Autostart programs
-- From autostart.conf.bak:6-9
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
	-- Authentication / Secret Service
	hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")

	-- System / Storage
	hl.exec_cmd("udiskie --automount --notify")

	-- Desktop UI
	hl.exec_cmd("waybar")
	hl.exec_cmd("waybar -c ~/.config/waybar/dock.jsonc -s ~/.config/waybar/dock.css")
	hl.exec_cmd("mako")

	-- Audio
	hl.exec_cmd("easyeffects --gapplication-service")

	-- Wallpaper
	hl.exec_cmd("awww-daemon")

	-- Clipboard
	hl.exec_cmd("wl-paste --watch cliphist store")

	-- AI / Development
	hl.exec_cmd("headroom proxy --port 8787")
	hl.exec_cmd("9router")
end)
