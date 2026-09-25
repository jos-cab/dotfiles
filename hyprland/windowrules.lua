-- windowrules.lua - Window and workspace rules
-- From windowrules.conf.bak:19
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
hl.window_rule({
    name   = "xdg-portal-gtk-float-center",
    match  = { class = "Xdg-desktop-portal-gtk" },
    float  = true,
    center = true,
    border_size = 0,
})
