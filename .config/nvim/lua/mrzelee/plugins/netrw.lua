-- Configurations
vim.g.netrw_list_hide = '\\(^\\|\\s\\s\\)\\zs\\.\\S\\+'
vim.g.netrw_hide = 1

-- Create or get an autocommand group
local group = vim.api.nvim_create_augroup('netrw_mappings', { clear = true })

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
-- delete buffer with :bdelete and then execute vim.Cmd.Ex in normal mode with <leader>pV
vim.keymap.set("n", "<leader>pV", function()
    if #GetBufferList() > 0 then
        vim.cmd.bprevious()
        vim.cmd.split()
        local ok, _ = pcall(vim.cmd, 'bnext')
        if not ok then
            vim.cmd.only()
        else
            ok, _ = pcall(vim.cmd, "bdelete")
            if not ok then
                vim.cmd.quit()
            end
        end
    end
    vim.cmd.Ex()
    for num, name in pairs(GetBufferList()) do
        if name == "[No Name]" then
            vim.cmd(num .. 'bdelete!')
        end
    end
end)


vim.api.nvim_create_autocmd('FileType', {
    pattern = 'netrw',
    callback = function()
        -- Use pcall to silently handle any errors when deleting the keymap
        local _, _ = pcall(vim.api.nvim_buf_del_keymap, 0, 'n', '<C-l>')
        -- if not ok then
            -- If you want to do something in case of an error (like logging), you can do it here
            -- print("Error deleting keymap: " .. err)
        -- end
    end,
    group = vim.api.nvim_create_augroup('netrw_mappings', { clear = true })
})

return {
    'prichrd/netrw.nvim',
    opts = {},
    config = function ()
        require("netrw").setup({})
    end
}
