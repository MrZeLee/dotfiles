-- Extract markdownlint code from a single diagnostic
local function get_markdownlint_code(diag)
  if not diag then return nil end
  -- Try direct code field
  if diag.code then return tostring(diag.code) end
  -- Try user_data.lsp.code (nvim-lint, efm, etc.)
  local ud = diag.user_data
  if ud then
    if ud.lsp and ud.lsp.code then return tostring(ud.lsp.code) end
    if ud.code then return tostring(ud.code) end
  end
  -- Extract MD code from message anywhere (e.g., "MD001" or "MD001/heading-increment")
  local code = diag.message:match("(MD%d+)")
  if code then return code end
  -- Try source field if it contains the code
  if diag.source and diag.source:match("MD%d+") then
    return diag.source:match("(MD%d+)")
  end
  return nil
end

-- Collect all unique markdownlint codes from diagnostics
local function get_all_codes(diags)
  local seen = {}
  local codes = {}
  for _, diag in ipairs(diags) do
    local code = get_markdownlint_code(diag)
    if code and not seen[code] then
      seen[code] = true
      table.insert(codes, code)
    end
  end
  return table.concat(codes, " ")
end

-- Disable current line (normal mode)
vim.keymap.set("n", "<localleader>d", function()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local diags = vim.diagnostic.get(0, { lnum = row - 1 })
  local codes = get_all_codes(diags)
  local comment = string.format(" <!-- markdownlint-disable-line %s -->", codes)
  local line = vim.api.nvim_get_current_line()
  vim.api.nvim_set_current_line(line .. comment)
end, { buffer = true, desc = "Markdownlint: disable current line" })

-- Wrap selection with disable/enable (visual mode)
vim.keymap.set("v", "<localleader>d", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
  local start_row = vim.fn.line("'<")
  local end_row = vim.fn.line("'>")

  -- Collect codes from all lines in selection
  local all_diags = {}
  for lnum = start_row - 1, end_row - 1 do
    for _, diag in ipairs(vim.diagnostic.get(0, { lnum = lnum })) do
      table.insert(all_diags, diag)
    end
  end
  local codes = get_all_codes(all_diags)

  vim.api.nvim_buf_set_lines(0, end_row, end_row, false, {
    string.format("<!-- markdownlint-enable %s -->", codes),
  })
  vim.api.nvim_buf_set_lines(0, start_row - 1, start_row - 1, false, {
    string.format("<!-- markdownlint-disable %s -->", codes),
  })
end, { buffer = true, desc = "Markdownlint: wrap selection with disable/enable" })