return {
	"tpope/vim-fugitive",
	version = "*",
	config = function()
		vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "access vim-fugitive" })
	end,
}
