return {
  {
    "3rd/diagram.nvim",
    dependencies = {
      { "3rd/image.nvim", opts = {} },
    },
    opts = {
      events = {
        render_buffer = {},
        clear_buffer = { "BufLeave" },
      },
      renderer_options = {
        mermaid = {
          background = nil,
          theme = dark,
          scale = 2,
          width = 1920,
          height = nil,
          cli_args = { "--no-sandbox" },
        },
        plantuml = {
          charset = nil,
          cli_args = nil,
        },
        d2 = {
          theme_id = nil,
          dark_theme_id = nil,
          scale = nil,
          layout = nil,
          sketch = nil,
          cli_args = nil,
        },
        gnuplot = {
          size = nil,
          font = nil,
          theme = nil,
          cli_args = nil,
        },
      },
    },
    keys = {
      {
        "<localleader>K", -- or any key you prefer
        function()
          require("diagram").show_diagram_hover()
        end,
        mode = "n",
        ft = { "markdown", "norg" }, -- Only in these filetypes
        desc = "Show diagram in new tab",
      },
    },
  },
}
