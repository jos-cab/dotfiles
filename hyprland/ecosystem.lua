-- ecosystem.lua - Permissions and ecosystem
-- From hyprland.conf.bak:42-45
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
hl.config({
    ecosystem = {
        no_update_news = true,
        -- enforce_permissions = true, -- uncomment to enforce
    },
})
-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")
