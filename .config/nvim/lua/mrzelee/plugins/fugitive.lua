return {
    'tpope/vim-fugitive',
    tag = 'v3.7',
    config = function()
        vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
    end
}
