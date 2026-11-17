-- ~/.config/nvim/lua/plugins/claudecode.lua
-- Inside a workspace with a Claude dev container (a claude.sh next to a
-- .devcontainer/, e.g. ~/Documents/01-Git/cibus), run Claude in the container
-- through that claude.sh; everywhere else, the plain claude binary.
-- shortcut: picked from the directory nvim starts in, so a later :cd into
-- or out of such a workspace keeps the first choice; restart nvim to switch.
return {
  "coder/claudecode.nvim",
  opts = function(_, opts)
    local devcontainer = vim.fs.find(".devcontainer", {
      upward = true,
      type = "directory",
      path = vim.fn.getcwd(),
      stop = vim.env.HOME,
    })[1]
    local launcher = devcontainer and vim.fs.dirname(devcontainer) .. "/claude.sh"
    if launcher and vim.fn.executable(launcher) == 1 then
      opts.terminal_cmd = launcher
    end
  end,
}
