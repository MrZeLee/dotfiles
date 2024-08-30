-- brew install ripgrep
return {
    {
    "nvim-telescope/telescope.nvim",

    tag = "0.1.8",

    dependencies = {
        "nvim-lua/plenary.nvim"
    },

    config = function()
        require('telescope').setup({})

        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
        vim.keymap.set('n', '<C-p>', builtin.git_files, {})
        vim.keymap.set('n', '<leader>ps', function()
            builtin.grep_string({
                search = vim.fn.input("Grep > "),
                vimgrep_arguments = { 'rg', '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case', '--hidden' }
            })
        end)
        vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})
    end
    },
    {
        "nvim-telescope/telescope-ui-select.nvim",
        config = function()
            require('telescope').setup({
                extension = {
                    require('telescope.themes').get_dropdown {
                    }
                }
            })
            require("telescope").load_extension("ui-select")
        end
    }
}


--require('telescope').setup({
--  defaults = {
--    layout_config = {
--      vertical = { width = 0.5 }
--      -- other layout configuration here
--    },
--    -- other defaults configuration here
--  },
--  -- other configuration values here
--})
