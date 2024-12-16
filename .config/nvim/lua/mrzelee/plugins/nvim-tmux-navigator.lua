return {
    'MrZeLee/nvim-tmux-navigation',

    config = function()

        local nvim_tmux_nav = require('nvim-tmux-navigation')

        nvim_tmux_nav.setup {
            disable_when_zoomed = false, -- defaults to false
            no_wrap = true -- defaults to false
        }

        vim.keymap.set({'n','t'}, "<C-h>", nvim_tmux_nav.NvimTmuxNavigateLeft, {desc="Navigate tmux Left"})
        vim.keymap.set({'n','t'}, "<C-j>", nvim_tmux_nav.NvimTmuxNavigateDown, {desc="Navigate tmux Down"})
        vim.keymap.set({'n','t'}, "<C-k>", nvim_tmux_nav.NvimTmuxNavigateUp, {desc="Navigate tmux Up"})
        vim.keymap.set({'n','t'}, "<C-l>", nvim_tmux_nav.NvimTmuxNavigateRight, {desc="Navigate tmux Right"})
        vim.keymap.set({'n','t'}, "<C-\\>", nvim_tmux_nav.NvimTmuxNavigateLastActive, {desc="Navigate tmux to lastActive"})
        vim.keymap.set({'n','t'}, "<C-Space>", nvim_tmux_nav.NvimTmuxNavigateNext, {desc="Navigate tmux to next"})

    end
}
