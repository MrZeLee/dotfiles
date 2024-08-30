function Map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.keymap.set(mode, lhs, rhs, options)
end

--vim.g.mapleader = " "
Map("n", "<F9>", "<C-]>")
Map("t", "<Esc>", "<C-\\><C-n>")

-- -- Movement windows
-- Map("n", "<C-h>", "<C-w>h")
-- Map("n", "<C-j>", "<C-w>j")
-- Map("n", "<C-k>", "<C-w>k")
-- Map("n", "<C-l>", "<C-w>l")
--
-- -- terminal
-- Map("t", "<C-h>", "<cmd>wincmd h<CR>")
-- Map("t", "<C-j>", "<cmd>wincmd j<CR>")
-- Map("t", "<C-k>", "<cmd>wincmd k<CR>")
-- Map("t", "<C-l>", "<cmd>wincmd l<CR>")

Map("n", "<A-Up>", ":resize -2<CR>")
Map("n", "<A-Down>", ":resize +2<CR>")
Map("n", "<A-Left>", ":vertical resize -2<CR>")
Map("n", "<A-Right>", ":vertical resize +2<CR>")

-- terminal
Map("t", "<A-Up>", "<cmd>resize -2<CR>")
Map("t", "<A-Down>", "<cmd>resize +2<CR>")
Map("t", "<A-Left>", "<cmd>vertical resize -2<CR>")
Map("t", "<A-Right>", "<cmd>vertical resize +2<CR>")

Map("v", "<", "<gv")
Map("v", ">", ">gv")

Map("n", "J", "mzJ`z")
Map("n", "<C-d>", "<C-d>zz")
Map("n", "<C-u>", "<C-u>zz")
Map("n", "n", "nzzzv")
Map("n", "N", "Nzzzv")

Map("x", "<leader>P", "\"_dP")
Map({"n","v"}, "<leader>y", "\"+y")
Map({"n"}, "<leader>Y", "\"+Y")
Map({"n", "v"}, "<leader>d", [["_d]])

Map("v", "J", ":m '>+1<CR>gv=gv")
Map("v", "K", ":m '<-2<CR>gv=gv")

Map("i", "<C-c>", "<Plug>(copilot-dismiss)<Esc>")
Map("i", "<Esc>", "<Plug>(copilot-dismiss)<Esc>")

-- vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
-- vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set({"n","t","i"}, "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

Map("n", "<leader>pn", "<cmd>bnext<CR>") -- next buffer
Map("n", "<leader>pp", "<cmd>bprevious<CR>") -- previous buffer
Map("n", "<leader>px", function()
    local ok ,err
    if #GetBufferList() > 1 then
        vim.cmd.bprevious()
        vim.cmd.split()
        ok, _ = pcall(vim.cmd, 'bnext')
        if not ok then
            vim.cmd.only()
        else
            ok, _ = pcall(vim.cmd, "bdelete")
            if not ok then
                vim.cmd.quit()
            end
        end
    else
        ok, _ = pcall(vim.cmd, "bdelete")
        if not ok then
            ok, err = vim.cmd.quit()
            if not ok then
                vim.echoerr(err)
                return
            end
        end
        vim.cmd.Ex()
    end
    for num, name in pairs(GetBufferList()) do
        if name == "[No Name]" then
            vim.cmd(num .. 'bdelete!')
        end
    end
end)
