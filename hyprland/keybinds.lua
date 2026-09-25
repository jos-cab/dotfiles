-- keybinds.lua - All keybindings
-- From keybinds.conf.bak:8-158
-- Requires programs.lua (terminal, fileManager, etc and mainMod) to be loaded first

-- Terminal / Apps
hl.bind(mainMod .. " + Return",       hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E",            hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + B",            hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + D",            hl.dsp.exec_cmd(discord))
hl.bind(mainMod .. " + S",            hl.dsp.exec_cmd(spotify))
hl.bind(mainMod .. " + M",            hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + C",            hl.dsp.window.close())
hl.bind(mainMod .. " + V",            hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + Q",    hl.dsp.exit())

hl.bind(mainMod .. " + U",            hl.dsp.exec_cmd("~/.config/hypr/scripts/update-packages"))
hl.bind(mainMod .. " + P",            hl.dsp.exec_cmd("~/.config/hypr/scripts/color-picker"))
hl.bind(mainMod .. " + SHIFT + V",    hl.dsp.exec_cmd("~/.config/hypr/scripts/clipboard-history"))

-- Screenshot
hl.bind("Print",                      hl.dsp.exec_cmd("~/.config/hypr/scripts/capture-selection screenshot"))
hl.bind(mainMod .. " + SHIFT + O",    hl.dsp.exec_cmd("~/.config/hypr/scripts/capture-selection ocr"))
hl.bind(mainMod .. " + SHIFT + R",    hl.dsp.exec_cmd("~/.config/hypr/scripts/capture-selection qr"))

-- Waybar
hl.bind(mainMod .. " + W",            hl.dsp.exec_cmd("killall -SIGUSR1 waybar"))

-- Focus navigation - Arrow keys
hl.bind(mainMod .. " + left",         hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right",        hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",           hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",         hl.dsp.focus({ direction = "down" }))
-- Vim-like keys
hl.bind(mainMod .. " + H",            hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + J",            hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + K",            hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + L",            hl.dsp.focus({ direction = "right" }))

-- Workspaces: Switch
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
end
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))

-- Move active window to workspace
for i = 1, 9 do
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + apostrophe",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + apostrophe", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Mouse window control (bindm -> mouse = true)
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Keyboard window control
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

-- Move floating windows in 20-pixel increments (binde -> repeating = true)
hl.bind(mainMod .. " + ALT + H", hl.dsp.window.move({ x = -20, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + J", hl.dsp.window.move({ x = 0, y = 20, relative = true }),  { repeating = true })
hl.bind(mainMod .. " + ALT + K", hl.dsp.window.move({ x = 0, y = -20, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + L", hl.dsp.window.move({ x = 20, y = 0, relative = true }),  { repeating = true })

hl.bind(mainMod .. " + CTRL + H", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.resize({ x = 0, y = 20, relative = true }),  { repeating = true })
hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + L", hl.dsp.window.resize({ x = 20, y = 0, relative = true }),  { repeating = true })

-- Adjust gaps
hl.bind(mainMod .. " + minus",        hl.dsp.exec_cmd("~/.config/hypr/scripts/adjust_gaps out dec"), { repeating = true })
hl.bind(mainMod .. " + plus",         hl.dsp.exec_cmd("~/.config/hypr/scripts/adjust_gaps out inc"), { repeating = true })
hl.bind(mainMod .. " + SHIFT + minus",hl.dsp.exec_cmd("~/.config/hypr/scripts/adjust_gaps in dec"),  { repeating = true })
hl.bind(mainMod .. " + SHIFT + plus", hl.dsp.exec_cmd("~/.config/hypr/scripts/adjust_gaps in inc"),  { repeating = true })

-- Borders
hl.bind(mainMod .. " + CTRL + minus", hl.dsp.exec_cmd("~/.config/hypr/scripts/adjust_gaps border dec"), { repeating = true })
hl.bind(mainMod .. " + CTRL + plus",  hl.dsp.exec_cmd("~/.config/hypr/scripts/adjust_gaps border inc"), { repeating = true })
hl.bind(mainMod .. " + SHIFT + bracketleft",  hl.dsp.exec_cmd("~/.config/hypr/scripts/adjust_gaps rounding dec"), { repeating = true })
hl.bind(mainMod .. " + SHIFT + bracketright", hl.dsp.exec_cmd("~/.config/hypr/scripts/adjust_gaps rounding inc"), { repeating = true })
hl.bind(mainMod .. " + braceleft",             hl.dsp.exec_cmd("~/.config/hypr/scripts/adjust_gaps rounding dec"), { repeating = true })
hl.bind(mainMod .. " + braceright",            hl.dsp.exec_cmd("~/.config/hypr/scripts/adjust_gaps rounding inc"), { repeating = true })

-- Media keys (requires playerctl)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- System keys
hl.bind(mainMod .. " + SHIFT + Delete", hl.dsp.exec_cmd("poweroff"))
hl.bind(mainMod .. " + CTRL + Delete",  hl.dsp.exec_cmd("reboot"))
hl.bind("CTRL + ALT + Delete",          hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind(mainMod .. " + ALT + Delete",   hl.dsp.exec_cmd("hyprctl kill"))

-- Additional keybindings
hl.bind(mainMod .. " + ALT + Return", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + Space",        hl.dsp.window.float({ action = "toggle" }))

-- Quick resize and move (duplicate of above with arrow keys, binde -> repeating)
hl.bind(mainMod .. " + ALT + Up",    hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + Down",  hl.dsp.window.resize({ x = 0, y = 20, relative = true }),  { repeating = true })
hl.bind(mainMod .. " + ALT + Left",  hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + Right", hl.dsp.window.resize({ x = 20, y = 0, relative = true }),  { repeating = true })

hl.bind(mainMod .. " + CTRL + Up",    hl.dsp.window.move({ x = 0, y = -20, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + Down",  hl.dsp.window.move({ x = 0, y = 20, relative = true }),  { repeating = true })
hl.bind(mainMod .. " + CTRL + Left",  hl.dsp.window.move({ x = -20, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + Right", hl.dsp.window.move({ x = 20, y = 0, relative = true }),  { repeating = true })
