function ColorMyPencils(color)
    color = color or "rose-pine"
    vim.cmd.colorscheme(color)

    --vim.api.nvim_set_hl(0, "Normal", { bg = "none"})
    --vim.api.nvim_set_hl(0, "Normal", { sp = "none"})
    --vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    --vim.api.nvim_set_hl(0, "NormalFloat", { blend = 0 })
end

return {
    {
        'rose-pine/neovim',
        name = 'rose-pine',
        --commit = '9d7474f80afe2f0cfcb4fabfc5451f509d844b85',
        tag = 'v3.0.1',
        lazy = false,
        priority = 1000,
        config = function()
            require('rose-pine').setup({
                styles = {
                    transparency = true,
                },
                -- dim_inactive_windows = true,
                highlight_groups = {
                    -- Normal = { bg = "..." },
                    -- Comment = { fg = "foam" },
                    -- VertSplit = { fg = "none", bg = "none" },
                    --WinSeparator = { fg = "none", bg = "none" },
                    --TelescopeBorder = { fg = "highlight_high", bg = "none" },
                    --TelescopeNormal = { bg = "none" },
                    --TelescopePromptNormal = { bg = "base" },
                    --TelescopeResultsNormal = { fg = "subtle", bg = "none" },
                    --TelescopeSelection = { fg = "text", bg = "base" },
                    --TelescopeSelectionCaret = { fg = "rose", bg = "rose" },
                },
            })
            ColorMyPencils()
            vim.cmd "highlight CopilotSuggestion ctermfg=8 guifg=#c2a57a"
        end
    },
}
