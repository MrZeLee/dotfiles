-- ~/.config/nvim/lua/plugins/lazygit.lua
return {
  "folke/snacks.nvim",
  opts = {
    lazygit = {
      configure = true,
      config = {
        os = {
          edit = '[ -z "$NVIM" ] && (nvim -- {{filename}}) || (nvim --server "$NVIM" --remote-send "<C-\\><C-N>:q<CR>" && nvim --server "$NVIM" --remote-send ":e {{filename}}<CR>")',
          editAtLine = '[ -z "$NVIM" ] && (nvim +{{line}} -- {{filename}}) || (nvim --server "$NVIM" --remote-send "<C-\\><C-N>:q<CR>" && nvim --server "$NVIM" --remote-send ":e {{filename}}<CR>:{{line}}<CR>")',
        },
      },
    },
  },
}
