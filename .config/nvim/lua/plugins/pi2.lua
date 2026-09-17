return {
  "zgs225/pi2.nvim",
  dependencies = { "MeanderingProgrammer/render-markdown.nvim" },

  -- Checked against the custom mappings in lua/ and ftplugin/; these <leader>p
  -- mappings are currently unused. LazyVim's default mappings also do not
  -- define these exact combinations.
  keys = {
    {
      "<leader>pp",
      function()
        vim.cmd("Pi layout=side")
      end,
      mode = { "n", "v" },
      desc = "Pi side panel",
    },
    {
      "<leader>pf",
      function()
        vim.cmd("Pi layout=float")
      end,
      mode = { "n", "v" },
      desc = "Pi floating panel",
    },
    {
      "<leader>pl",
      "<cmd>PiToggleLayout<cr>",
      mode = { "n", "v" },
      desc = "Pi toggle layout",
    },
    {
      "<leader>pc",
      "<cmd>PiContinue<cr>",
      mode = { "n", "v" },
      desc = "Pi continue session",
    },
    {
      "<leader>pr",
      "<cmd>PiResume<cr>",
      mode = { "n", "v" },
      desc = "Pi resume session",
    },
    {
      "<leader>pm",
      "<cmd>PiSendMention<cr>",
      mode = { "n", "v" },
      desc = "Pi mention file or selection",
    },
    {
      "<leader>pa",
      "<cmd>PiAttention<cr>",
      mode = { "n", "v" },
      desc = "Pi open attention request",
    },
  },

  config = true,
}
