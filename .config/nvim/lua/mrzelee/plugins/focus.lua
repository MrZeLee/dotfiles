return {
	"nvim-focus/focus.nvim",
	version = false,
	config = function()
		require("focus").setup({
			autoresize = {
        width = 90,
				minwidth = 3, -- Force minimum width for the unfocused window
				minheight = 3, -- Force minimum height for the unfocused window
			},
		})
	end,
	opts = {
		-- split = {
		--     bufnew = true,
		-- },
		-- options
	},
}
