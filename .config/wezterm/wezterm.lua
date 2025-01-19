local wezterm = require 'wezterm'

-- local xcursor_size = nil
-- local xcursor_theme = nil

-- local success, stdout, stderr = wezterm.run_child_process({"gsettings", "get", "org.gnome.desktop.interface", "cursor-theme"})
-- if success then
--   xcursor_theme = stdout:gsub("'(.+)'\n", "%1")
-- end
-- 
-- local success, stdout, stderr = wezterm.run_child_process({"gsettings", "get", "org.gnome.desktop.interface", "cursor-size"})
-- if success then
--   xcursor_size = tonumber(stdout)
-- end

-- Determine the OS
local target_triple = wezterm.target_triple
local is_linux = target_triple:find("linux") ~= nil
local is_macos = target_triple:find("darwin") ~= nil
-- local is_windows = target_triple:find("windows") ~= nil

-- Base configuration
local config = {
  -- Spawn a zsh shell in login mode
  default_prog = { '/run/current-system/sw/bin/zsh' },

  -- Environment variables
  set_environment_variables = {
    TERM = "xterm-256color",
  },

  -- Window settings
  window_padding = {
    left = 10,
    right = 10,
    top = 10,
    bottom = 10,
  },
  window_decorations = "RESIZE",
  window_background_opacity = 1.0,
  initial_rows = 24,
  initial_cols = 80,
  window_close_confirmation = "NeverPrompt",

  -- Startup mode
  launch_menu = {
    {
      label = "Windowed Mode",
      args = { "wezterm", "start" },
    },
  },

  -- Font settings
  font = wezterm.font_with_fallback {
    "Hack Nerd Font",
  },
  font_size = 12.0, -- Default for Linux
  line_height = 1.0,

  -- Cursor settings
  default_cursor_style = "SteadyBlock",

  -- Scrollback settings
  scrollback_lines = 10000,

  color_scheme = 'Catppuccin Mocha',

  -- IPC and dynamic title
  automatically_reload_config = true,
  use_fancy_tab_bar = false,
  enable_tab_bar = false,

  front_end = "WebGpu",
  enable_wayland = true,
}

-- OS-specific configurations
if is_linux then
  config.font_size = 12.0
  config.mux_enable_ssh_agent = false
elseif is_macos then
  config.font_size = 14.0
end

return config
