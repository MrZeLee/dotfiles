local wezterm = require 'wezterm'

local target_triple = wezterm.target_triple
local is_linux = target_triple:find("linux") ~= nil
local is_macos = target_triple:find("darwin") ~= nil

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

  max_fps = 120,
}


if is_linux then
  config.window_decorations = "NONE"
  config.font_size = 12.0
  config.mux_enable_ssh_agent = false
  config.enable_wayland = true
elseif is_macos then
  config.font_size = 14.0
  -- config.front_end = true
end
return config
