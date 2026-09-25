-- layouts.lua - Layout settings
-- From layouts.conf.bak:12-20
hl.config({
    dwindle = {
        preserve_split = true,
    },
})
hl.config({
    master = {
        new_status = "master",
    },
})
-- Smart gaps (commented in original) - uncomment to enable:
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({ name = "bordersize-wtv1", match = { workspace = "w[tv1]", float = false }, border_size = 0, rounding = 0 })
-- hl.window_rule({ name = "bordersize-f1",   match = { workspace = "f[1]",   float = false }, border_size = 0, rounding = 0 })
