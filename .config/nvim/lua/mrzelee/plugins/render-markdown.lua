return {
  "MeanderingProgrammer/render-markdown.nvim",
  -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
  -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons

  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    file_types = { "markdown", "Avante" },
  },
  ft = { "markdown", "Avante" },

  config = function ()
    -- Extend cmp for Markdown filetype only
    local cmp = require("cmp")
    cmp.setup.filetype({ "markdown", "Avante" }, {
      sources = cmp.config.sources({
        { name = "render-markdown" },
      }, {
        -- In the second table, put the "fallback" sources
        { name = "nvim_lsp" },
        { name = "buffer" },
        { name = "path" },
      }),
    })
  end

}
