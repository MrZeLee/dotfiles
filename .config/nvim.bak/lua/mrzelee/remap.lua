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
-- added buffer = true so it works with which-key plugin
Map("n", "<C-d>", "<C-d>zz", { desc = 'Jump half page down', buffer = true})
Map("n", "<C-u>", "<C-u>zz", { desc = 'Jump half page up', buffer = true})
Map("n", "n", "nzzzv")
Map("n", "N", "Nzzzv")

Map("x", "<leader>P", "\"_dP")
Map({"n","v"}, "<leader>y", "\"+y")
Map({"n"}, "<leader>Y", "\"+Y")
Map({"n", "v"}, "<leader>d", [["_d]])

Map("v", "J", ":m '>+1<CR>gv=gv")
Map("v", "K", ":m '<-2<CR>gv=gv")

-- Map("i", "<C-c>", "<Plug>(copilot-dismiss)<Esc>")
-- Map("i", "<Esc>", "<Plug>(copilot-dismiss)<Esc>")

-- vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
-- vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set({"n","t","i"}, "<C-f>", "<cmd>silent !tmux neww -n 'sessionizer' bash -c 'tmux-sessionizer'<CR>")

-- Map("n", "<leader>pn", "<cmd>bnext<CR>") -- next buffer
-- Map("n", "<leader>pp", "<cmd>bprevious<CR>") -- previous buffer
-- Map("n", "<leader>px", function()
--     local ok ,err
--     if #GetBufferList() > 1 then
--         vim.cmd.bprevious()
--         vim.cmd.split()
--         ok, _ = pcall(vim.cmd, 'bnext')
--         if not ok then
--             vim.cmd.only()
--         else
--             ok, _ = pcall(vim.cmd, "bdelete")
--             if not ok then
--                 vim.cmd.quit()
--             end
--         end
--     else
--         ok, _ = pcall(vim.cmd, "bdelete")
--         if not ok then
--             ok, err = vim.cmd.quit()
--             if not ok then
--                 vim.echoerr(err)
--                 return
--             end
--         end
--         vim.cmd.Ex()
--     end
--     for num, name in pairs(GetBufferList()) do
--         if name == "[No Name]" then
--             vim.cmd(num .. 'bdelete!')
--         end
--     end
-- end)
--

-- I'm switching from bufexplorer to telescope buffers as I get a file preview,
-- that's basically the main benefit lamw25wmal
vim.keymap.set(
    "n",
    "<leader>hh",
    -- Notice that I start it in normal mode to navigate similarly to bufexplorer,
    -- the ivy theme is also similar to bufexplorer and tmux sessions
    "<cmd>Telescope buffers sort_mru=true sort_lastused=true initial_mode=normal theme=ivy<cr>",
    { desc = "[P]Open telescope buffers" }
)

-- Copy full file path in Netrw or normal buffer to the clipboard
vim.keymap.set("n", "<leader>fp", function()
  local filePath

  -- Check if we are in Netrw
  if vim.bo.filetype == "netrw" then
    -- Get the absolute path of the file under the cursor in Netrw
    filePath = vim.fn.fnamemodify(vim.fn.expand("<cfile>"), ":p")
  else
    -- Get the absolute path of the current file in normal buffers
    filePath = vim.fn.expand("%:p") -- Absolute file path
  end

  -- Copy the file path to the clipboard register
  vim.fn.setreg("+", filePath)
  -- Optional: print message to confirm
  print("File path copied to clipboard: " .. filePath)
end, { desc = "[P]Copy full file path to clipboard" })

-- Escape Lua pattern magic characters.
local function escape_lua_pattern(s)
  return s:gsub("([%^%$%(%)%%%.%[%]*%+%-%?])", "%%%1")
end

-- Toggle formatting for the current visual selection.
local function ToggleFormatting(fmt)
   -- In visual mode, first yank the selection into register 'z'
  vim.cmd('normal! "zy')
  -- Now delete the selection (which clears it, but we already have the text in 'z')
  vim.cmd('normal! gv"_d')
  -- Retrieve the yanked text
  local s = vim.fn.getreg('z')
  local escaped_fmt = fmt:gsub("([%^%$%(%)%%%.%[%]*%+%-%?])", "%%%1")
  local pattern = "^" .. escaped_fmt .. "(.-)" .. escaped_fmt .. "$"
  local inner = s:match(pattern)
  local new_text = inner or (fmt .. s .. fmt)
  -- Paste the new text
  vim.cmd("normal! i" .. new_text .. vim.api.nvim_replace_termcodes("<Esc>", true, false, true))
end

-- Function to toggle formatting for the word under the cursor (normal mode)
local function ToggleFormattingNormal(fmt)
  -- Use <cWORD> to capture the entire contiguous word (which may include formatting markers)
  local cur_word = vim.fn.expand("<cWORD>")
  local escaped_fmt = escape_lua_pattern(fmt)
  local pattern = "^" .. escaped_fmt .. "(.-)" .. escaped_fmt .. "$"
  local inner = cur_word:match(pattern)
  local new_word = inner or (fmt .. cur_word .. fmt)
  -- Replace the WORD using 'ciW' (change inner WORD)
  vim.cmd("normal! ciW" .. new_word .. vim.api.nvim_replace_termcodes("<Esc>", true, false, true))
end

-- Create an autocommand for Markdown files.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()

    -- Visual mode mappings for toggling formatting on the selected text.
    vim.keymap.set("v", "<localleader>b", function() ToggleFormatting("**") end, {
      buffer = true,
      desc = "Toggle bold formatting on selection"
    })
    vim.keymap.set("v", "<localleader>i", function() ToggleFormatting("_") end, {
      buffer = true,
      desc = "Toggle italic formatting on selection"
    })
    vim.keymap.set("v", "<localleader>s", function() ToggleFormatting("~~") end, {
      buffer = true,
      desc = "Toggle strikethrough formatting on selection"
    })
    vim.keymap.set("v", "<localleader>`", function() ToggleFormatting("`") end, {
      buffer = true,
      desc = "Toggle inline code formatting on selection"
    })
    vim.keymap.set('v', '<localleader>t', 'c[<c-r>"]()<left>', {
      buffer = true,
      desc = "Wrap selection as Markdown link [text](), place cursor in URL"
    })
    vim.keymap.set('v', '<localleader>u', 'c[](<c-r>")<c-o>F]', {
      buffer = true,
      desc = "Wrap selection as Markdown link [](text), place cursor in title"
    })

    -- Normal mode mappings for toggling formatting on the word under the cursor.
    vim.keymap.set("n", "<localleader>b", function() ToggleFormattingNormal("**") end, {
      buffer = true,
      desc = "Toggle bold formatting on word under cursor"
    })
    vim.keymap.set("n", "<localleader>i", function() ToggleFormattingNormal("_") end, {
      buffer = true,
      desc = "Toggle italic formatting on word under cursor"
    })
    vim.keymap.set("n", "<localleader>s", function() ToggleFormattingNormal("~~") end, {
      buffer = true,
      desc = "Toggle strikethrough formatting on word under cursor"
    })
    vim.keymap.set("n", "<localleader>`", function() ToggleFormattingNormal("`") end, {
      buffer = true,
      desc = "Toggle inline code formatting on word under cursor"
    })
    -- Selects the word and wraps it as [word](), positioning the cursor inside the parentheses for URL input.
    vim.keymap.set('n', '<localleader>t', 'viWc[<c-r>"]()<left>', {
      buffer = true,
      desc = "Wrap word under cursor as Markdown link [Word](), place cursor in URL"
    })
    -- Selects the word and wraps it as [](), then moves the cursor inside the brackets for the link text.
    vim.keymap.set('n', '<localleader>u', 'viWc[](<c-r>")<c-o>F]', {
      buffer = true,
      desc = "Wrap word under cursor as Markdown link [](Word), place cursor in title"
    })
  end,
})
