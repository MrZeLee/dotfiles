-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Enable the option to require a Prettier config file
-- If no prettier config file is found, the formatter will not be used
vim.g.lazyvim_prettier_needs_config = false

vim.opt.spelllang = { "en", "pt" }

-- Voice capture: the nixpkgs claude-code wrapper prepends its own alsa-lib to
-- LD_LIBRARY_PATH on every launch, and that build ships no plugin directory,
-- so ALSA cannot load libasound_module_pcm_pipewire.so and capture dies. The
-- system plugin is not usable either - it needs system glibc, and this is a
-- nix binary. Point ALSA at a nix-built pipewire plugin instead, and put its
-- lib dir on the path so libpipewire-0.3.so.0 resolves. Set here because
-- claudecode.nvim spawns the binary directly, so a shell wrapper never runs.
local nix_pipewire = vim.env.HOME .. "/.local/state/nix/gcroots/pipewire-alsa"
if vim.uv.fs_stat(nix_pipewire .. "/lib/alsa-lib") then
  vim.env.ALSA_PLUGIN_DIR = nix_pipewire .. "/lib/alsa-lib"
  vim.env.LD_LIBRARY_PATH = nix_pipewire .. "/lib:" .. (vim.env.LD_LIBRARY_PATH or "")
end
