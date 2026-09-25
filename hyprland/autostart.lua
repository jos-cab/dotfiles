-- autostart.lua - Autostart programs
-- From autostart.conf.bak:6-9
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
	hl.exec_cmd("udiskie --automount --notify")
	hl.exec_cmd("waybar")
	hl.exec_cmd("mako")
	hl.exec_cmd("awww-daemon")
	hl.exec_cmd("wl-paste --watch cliphist store")
	hl.exec_cmd("9router")
	hl.exec_cmd("headroom proxy --port 8787")
end)
