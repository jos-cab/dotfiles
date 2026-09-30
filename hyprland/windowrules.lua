-- windowrules.lua - Window and workspace rules
-- From windowrules.conf.bak:19
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
hl.window_rule({
	name = "xdg-portal-gtk-float-center",
	match = { class = "xdg-desktop-portal-gtk" },
	float = true,
	center = true,
	size = { 700, 550 },
})

hl.window_rule({
	name = "media-popup-no-animation",
	match = { title = "Media controls" },
	no_anim = true,
})
