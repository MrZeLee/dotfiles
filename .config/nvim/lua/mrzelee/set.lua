vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.g.netrw_banner = 0 -- Hide the netrw banner on top
-- vim.g.netrw_liststyle = 3

--vim.opt.clipboard = "unnamed"

vim.opt.cursorline = true

vim.opt.mouse = ""

vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.opt.tabstop = 2
		vim.opt.softtabstop = 2
		vim.opt.shiftwidth = 2
	end,
})

vim.opt.expandtab = true

-- Keep false to indent comments
vim.opt.smartindent = false

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "0"

vim.opt.textwidth = 80

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"
	end,
})

local servername = vim.v.servername
if servername == "" and vim.fn.exists("*remote_startserver") ~= 0 then
	vim.fn.remote_startserver("VIM")
end
