local wezterm = require 'wezterm'

return {
    -- Environment variables
    set_environment_variables = {
        WINIT_X11_SCALE_FACTOR = "1.0",
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
    font = wezterm.font_with_fallback{
        "Hack Nerd Font",
    },
    font_size = 14.0,
    line_height = 1.0,

    -- Cursor settings
    default_cursor_style = "SteadyBlock",

    -- Scrollback settings
    scrollback_lines = 10000,

    color_scheme = 'Catppuccin Mocha',

    -- IPC and dynamic title
    automatically_reload_config = true,
    enable_wayland = true, -- Use Wayland if available
    use_fancy_tab_bar = false,
    enable_tab_bar = false,
    -- dynamic_title = true,
}
