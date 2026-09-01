return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        marksman = {
          mason = false,
        },
        -- pyright only speaks utf-16, ruff negotiates utf-8, and both attach
        -- to the same python buffer: mismatched position encodings shift
        -- diagnostic and edit columns after any non-ascii character on a line.
        ruff = {
          capabilities = {
            general = { positionEncodings = { "utf-16" } },
          },
        },
      },
    },
  },
}
