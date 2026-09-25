-- input.lua - Input devices
-- From input.conf.bak:6-22
-- https://wiki.hypr.land/Configuring/Basics/Variables/#input
hl.config({
    input = {
        kb_layout          = "latam",
        numlock_by_default = true,
        repeat_rate        = 40,
        repeat_delay       = 200,
        follow_mouse       = 1,
    },
})
hl.device({
    name          = "razer-razer-naga-chroma",
    sensitivity   = 0.1,
    accel_profile = "flat",
})
