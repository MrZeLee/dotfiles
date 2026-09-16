-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set(
  { "n", "t", "i" },
  "<C-F>",
  "<cmd>silent !tmux neww -n 'sessionizer' bash -c 'tmux-sessionizer'<CR>",
  { desc = "Open Tmux Sessionizer" }
)

-- tuicr: surface the active review session's comments inside nvim.
--   :TuicrComments [slug]  list them in a tuicr://<slug> buffer; <CR> on a heading jumps there
--   line-anchored comments also show inline as diagnostics (]d to navigate, <leader>cd to float)
-- Defaults to the most recently seen active session (the one that spawned this nvim via `e`).
local tuicr_ns = vim.api.nvim_create_namespace("tuicr")
local tuicr_severity = { issue = "ERROR", suggestion = "WARN", note = "INFO" }
local tuicr_comments = {}

local function tuicr_active_slug()
  local path = (os.getenv("XDG_DATA_HOME") or vim.fn.expand("~/.local/share"))
    .. "/tuicr/reviews/active_sessions.json"
  local ok, raw = pcall(vim.fn.readfile, path)
  local sessions = ok and vim.json.decode(table.concat(raw)).sessions or {}
  table.sort(sessions, function(a, b)
    return a.last_seen_at > b.last_seen_at
  end)
  return sessions[1] and sessions[1].slug
end

local function tuicr_annotate(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  local diags = {}
  for _, c in ipairs(tuicr_comments) do
    if c.start_line and vim.fn.fnamemodify(c.path, ":p") == name then
      diags[#diags + 1] = {
        lnum = c.start_line - 1,
        end_lnum = c.end_line - 1,
        col = 0,
        message = c.content,
        source = "tuicr",
        severity = vim.diagnostic.severity[tuicr_severity[c.comment_type] or "HINT"],
      }
    end
  end
  vim.diagnostic.set(tuicr_ns, buf, diags)
end

local function tuicr_fetch(slug)
  local out = vim.system({ "tuicr", "review", "get", "--session", slug }, { text = true }):wait()
  if out.code ~= 0 then
    return vim.notify(out.stderr, vim.log.levels.ERROR)
  end
  tuicr_comments = vim.json.decode(out.stdout, { luanil = { object = true } })
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      tuicr_annotate(buf)
    end
  end
  return true
end

vim.api.nvim_create_user_command("TuicrComments", function(opts)
  local slug = opts.args ~= "" and opts.args or tuicr_active_slug()
  if not slug then
    return vim.notify("tuicr: no active session", vim.log.levels.WARN)
  end
  if not tuicr_fetch(slug) then
    return
  end
  local lines = { "# " .. slug, "" }
  for _, c in ipairs(tuicr_comments) do
    lines[#lines + 1] = ("## %s [%s]"):format(c.location or "(review)", c.comment_type or "none")
    vim.list_extend(lines, vim.split(c.content, "\n"))
    lines[#lines + 1] = ""
  end
  local name = "tuicr://" .. slug
  if vim.fn.bufexists(name) == 1 then
    vim.api.nvim_buf_delete(vim.fn.bufnr(name), { force = true })
  end
  vim.cmd("vnew")
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_name(buf, name)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].buftype, vim.bo[buf].bufhidden, vim.bo[buf].filetype = "nofile", "wipe", "markdown"
  vim.bo[buf].modifiable = false
  vim.keymap.set("n", "<CR>", function()
    local file, line = vim.api.nvim_get_current_line():match("^## ([^:%s]+):?(%d*) ")
    if file then
      vim.cmd.wincmd("p")
      vim.cmd.edit(file)
      if line ~= "" then
        vim.cmd(line)
      end
    end
  end, { buffer = buf, desc = "Jump to comment location" })
end, { nargs = "?", desc = "Show tuicr review comments" })

-- Inline diagnostics: fetch once per nvim (tuicr spawns a fresh one per `e`);
-- :TuicrComments refreshes. Files loaded before this ran are covered by the fetch.
local tuicr_slug = tuicr_active_slug()
if tuicr_slug and tuicr_fetch(tuicr_slug) then
  vim.api.nvim_create_autocmd("BufReadPost", {
    group = vim.api.nvim_create_augroup("tuicr", { clear = true }),
    callback = function(ev)
      tuicr_annotate(ev.buf)
    end,
  })
end
