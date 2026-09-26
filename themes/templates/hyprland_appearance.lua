-- appearance.lua - Look and feel
-- From appearance.conf.bak:8-76
-- Catppuccin Mocha Theme Colors
-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 10,
        border_size = 2,
        ["col.active_border"]   = "rgba(cba6f7ee)",
        ["col.inactive_border"] = "rgba(313244aa)",
        resize_on_border = true,
        allow_tearing  = true,
        layout = "dwindle",
    },
    decoration = {
        rounding       = 12,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 0.95,
        shadow = {
            enabled      = false,
            range        = 8,
            render_power = 3,
            color        = "rgba(1e1e2eee)",
        },
        blur = {
            enabled           = false,
            size              = 6,
            passes            = 2,
            new_optimizations = true,
            xray              = false,
            ignore_opacity    = false,
            vibrancy          = 0.2,
            vibrancy_darkness = 0.5,
            contrast          = 1.0,
            brightness        = 1.0,
            noise             = 0.02,
        },
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
        background_color = "rgba(1e1e2eff)",
        -- vrr = 1, -- uncomment to enable
    },
})
