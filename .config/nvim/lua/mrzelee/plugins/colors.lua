function ColorMyPencils(color)
    color = color or "catppuccin"
    vim.cmd.colorscheme(color)

    --vim.api.nvim_set_hl(0, "Normal", { bg = "none"})
    --vim.api.nvim_set_hl(0, "Normal", { sp = "none"})
    --vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    --vim.api.nvim_set_hl(0, "NormalFloat", { blend = 0 })
end

return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    tag = 'v1.9.0',
    lazy = false,
    config = function()
        require("catppuccin").setup({
            flavour = "mocha", -- latte, frappe, macchiato, mocha
            background = { -- :h background
                light = "latte",
                dark = "mocha",
            },
            transparent_background = false, -- disables setting the background color.
            show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
            term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
            dim_inactive = {
                enabled = false, -- dims the background color of inactive window
                shade = "dark",
                percentage = 0.15, -- percentage of the shade to apply to the inactive window
            },
            no_italic = false, -- Force no italic
            no_bold = false, -- Force no bold
            no_underline = false, -- Force no underline
            styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
                comments = { "italic" }, -- Change the style of comments
                conditionals = { "italic" },
                loops = {},
                functions = {},
                keywords = {},
                strings = {},
                variables = {},
                numbers = {},
                booleans = {},
                properties = {},
                types = {},
                operators = {},
                -- miscs = {}, -- Uncomment to turn off hard-coded styles
            },
            color_overrides = {},
            custom_highlights = {},
            default_integrations = true,
            integrations = {
                cmp = true,
                gitsigns = true,
                nvimtree = true,
                treesitter = true,
                notify = false,
                mini = {
                    enabled = true,
                    indentscope_color = "",
                },
                -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
            },
        })

        -- setup must be called before loading
        ColorMyPencils()
    end
    -- {
    --     'rose-pine/neovim',
    --     name = 'rose-pine',
    --     --commit = '9d7474f80afe2f0cfcb4fabfc5451f509d844b85',
    --     tag = 'v3.0.1',
    --     lazy = false,
    --     priority = 1000,
    --     config = function()
    --         require('rose-pine').setup({
    --             enable = {
    --                 terminal = true,
    --                 legacy_highlights = false,
    --             },
    --             styles = {
    --                 transparency = true,
    --             },
    --             dim_inactive_windows = false,
    --             highlight_groups = {
    --                 -- Normal = { bg = "..." },
    --                 -- Comment = { fg = "foam" },
    --                 -- VertSplit = { fg = "none", bg = "none" },
    --                 --WinSeparator = { fg = "none", bg = "none" },
    --                 --TelescopeBorder = { fg = "highlight_high", bg = "none" },
    --                 --TelescopeNormal = { bg = "none" },
    --                 --TelescopePromptNormal = { bg = "base" },
    --                 --TelescopeResultsNormal = { fg = "subtle", bg = "none" },
    --                 --TelescopeSelection = { fg = "text", bg = "base" },
    --                 --TelescopeSelectionCaret = { fg = "rose", bg = "rose" },
    --             },
    --         })
    --         ColorMyPencils()
    --         -- vim.cmd "highlight CopilotSuggestion ctermfg=8 guifg=#c2a57a"
    --     end
    -- },
}
