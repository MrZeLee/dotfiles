return {

    'nvim-treesitter/nvim-treesitter',
    tag = 'v0.9.3',
    -- build = function ()
    --     require("nvim-treesitter.install").update({ with_sync = true })()
    -- end,
    build = ":TSUpdate",

    config = function()
        local configs = require("nvim-treesitter.configs")
        configs.setup {
            -- A list of parser names, or "all" (the five listed parsers should always be installed)
            ensure_installed = { "comment", "markdown", "markdown_inline", "vimdoc", "c", "lua", "javascript", "latex", "python", "typescript", "vim", "query", "rust", "java", "nix", "yaml" },

            -- Install parsers synchronously (only applied to `ensure_installed`)
            sync_install = true,

            -- Automatically install missing parsers when entering buffer
            -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
            auto_install = true,

            indent = {
                enable = true
            },

            highlight = {
                enable = true,
                disable = {"latex"},

                -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
                -- Using this option may slow down your editor, and you may see some duplicate highlights.
                -- Instead of true it can also be a list of languages
                --
                additional_vim_regex_highlighting = false,
            },
            autotag = {
                enable = false,
            },
        }

        -- Adding folding
        vim.opt.foldmethod = "expr"
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.opt.foldlevelstart = 99
    end
}
