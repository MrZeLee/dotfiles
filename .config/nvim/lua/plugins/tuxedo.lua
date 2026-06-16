---@type LazySpec
return {
  "IogaMaster/tuxedo.nvim",
  cmd = "Tuxedo",
  keys = {
    { "<leader>td", "<cmd>Tuxedo<cr>", desc = "Open Tuxedo (TODO)" },
  },
  opts = {
    create_todo_file = true,
    width_ratio = 0.95,
    height_ratio = 0.80,
  },
}