return {
    'github/copilot.vim',
    tag = 'v1.39.0',
    config = function()
        vim.keymap.set({"i","n"}, "<C-q>c", "<Cmd>Copilot<CR>")

        vim.keymap.set("i", "<C-q>d", "<Plug>(copilot-dismiss)")
        vim.keymap.set("i", "<C-q>n", "<Plug>(copilot-next)")
        vim.keymap.set("i", "<C-q>p", "<Plug>(copilot-previous)")
        vim.keymap.set("i", "<C-q>s", "<Plug>(copilot-suggest)")
        vim.keymap.set("i", "<S-Tab>", "<Plug>(copilot-accept-word)")
        vim.keymap.set("i", "<C-q>l", "<Plug>(copilot-accept-line)")

    end
}
