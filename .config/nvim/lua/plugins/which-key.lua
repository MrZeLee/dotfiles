-- Track my fork of which-key.nvim (includes the keymap search feature) until the
-- PR is merged upstream. To revert to upstream, delete this whole file.
-- For local development instead, swap `url` for: dir = "/home/jmoura/Documents/01-Git/which-key.nvim"
return {
  "folke/which-key.nvim",
  url = "https://github.com/MrZeLee/which-key.nvim.git",
  branch = "main",
  keys = {
    {
      "<leader>sk",
      function()
        require("which-key").search()
      end,
      desc = "Search Keymaps (which-key)",
    },
  },
}
