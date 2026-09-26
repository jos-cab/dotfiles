-- #######################################################################################
-- MODULAR HYPRLAND LUA CONFIG
-- EDIT INDIVIDUAL FILES IN THE hyprland/ DIRECTORY
-- #######################################################################################
-- This is a modular Hyprland Lua config file.
-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/

-- Configuration is split into multiple files for better organization:
-- - monitors.lua:    Monitor configuration
-- - programs.lua:    Default programs and variables (also defines mainMod)
-- - autostart.lua:   Programs to start automatically
-- - environment.lua: Environment variables
-- - ecosystem.lua:   Ecosystem / permissions
-- - appearance.lua:  Visual settings (gaps, borders, colors, etc.)
-- - animations.lua:  Animation settings and bezier curves
-- - layouts.lua:     Layout settings (dwindle, master, workspaces)
-- - input.lua:       Input devices, keyboard, mouse, touchpad
-- - keybinds.lua:    All keybindings and shortcuts (depends on programs.lua)
-- - windowrules.lua: Window rules and workspace rules

-- Ensure Hyprland config directory is in Lua package.path
-- Hyprland 0.56+ preserves package.path, but we add config dir explicitly for robustness
local hyprDir = os.getenv("HOME") .. "/.config/hypr"
package.path = hyprDir .. "/?.lua;" .. hyprDir .. "/?/init.lua;" .. package.path
-- Also support dotfiles location directly (useful for standalone luac checks)
local dotfilesRoot = os.getenv("DOTFILES_DIR") or (os.getenv("HOME") .. "/dotfiles")
local dotfilesDir = dotfilesRoot .. "/hyprland"
package.path = dotfilesDir .. "/?.lua;" .. package.path

-- Source all configuration files - order mirrors original hyprland.conf source order
require("monitors")    -- monitors.lua
require("programs")    -- programs.lua (defines terminal, fileManager, mainMod, etc.)
require("autostart")   -- autostart.lua
require("environment") -- environment.lua
require("ecosystem")   -- ecosystem.lua
require("appearance")  -- appearance.lua
require("animations")  -- animations.lua
require("layouts")     -- layouts.lua
require("input")       -- input.lua
require("keybinds")    -- keybinds.lua (uses mainMod + program vars)
require("windowrules") -- windowrules.lua
