return {
  -- NOTE: If removed, also remove in the nvim-cmp sources
	"Dynge/gitmoji.nvim",
	dependencies = {
		-- Switch from nvim-cmp to Blink
		-- "hrsh7th/nvim-cmp", -- for nvim-cmp completion
		"Saghen/blink.cmp",    -- for Blink completion
	},
	opts = {
		filetypes = { "gitcommit" },
		completion = {
			append_space = false,
			complete_as = "emoji",
		},
	},
	ft = "gitcommit",
}
