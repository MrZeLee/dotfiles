return {
  -- "nvim-focus/focus.nvim",
	"MrZeLee/focus.nvim",
  branch = "master",
  -- dir = "/home/mrzelee/Documents/01-Git/focus.nvim/",
  -- dev = true,
	version = false,
	config = function()
		require("focus").setup({
			autoresize = {
				minwidth = 3, -- Force minimum width for the unfocused window
				minheight = 3, -- Force minimum height for the unfocused window
        focusedwindow_minwidth = 90,
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
