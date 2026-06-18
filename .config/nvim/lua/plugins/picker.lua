return {
  {
    "ibhagwan/fzf-lua",
    opts = {
      actions = {
        files = {
          ["alt-h"] = false,
          ["alt-u"] = { fn = require("fzf-lua").actions.toggle_hidden, reuse = true, header = false },
        },
      },
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        win = {
          input = {
            keys = {
              ["<C-h>"] = { "toggle_hidden", mode = { "i", "n" } },
            },
          },
        },
        sources = {
          explorer = {
            win = {
              list = {
                keys = {
                  ["<C-f>"] = { "tmux_sessionizer", mode = { "n", "i" } },
                },
              },
              input = {
                keys = {
                  ["<C-f>"] = { "tmux_sessionizer", mode = { "n", "i" } },
                },
              },
            },
            actions = {
              tmux_sessionizer = function()
                vim.cmd("silent !tmux neww -n 'sessionizer' bash -c 'tmux-sessionizer'")
              end,
            },
          },
        },
      },
      image = {
        math = { enabled = false },
        doc = {
          ft = { "markdown", "tex", "typst", "vimwiki" },
        },
      },
    },
  },
}

