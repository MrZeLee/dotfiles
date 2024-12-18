-- brew install ripgrep
return {
    {
    "nvim-telescope/telescope.nvim",

    tag = "0.1.8",

    dependencies = {
        "nvim-lua/plenary.nvim"
    },

    config = function()
        require('telescope').setup({
            defaults = {
                -- Path display settings
                path_display = {
                    "filename", -- Show filename first
                    shorten = { len = 3, exclude = { 1, -1 } }, -- Optionally shorten long paths
                },
                mappings = {
                    -- General mappings for Telescope
                    n = {
                        ["<esc>"] = require("telescope.actions").close,
                    },
                },
            },
            pickers = {
                buffers = {
                    mappings = {
                        n = {
                            -- Map "d" to delete buffer in the buffers picker
                            ["d"] = require("telescope.actions").delete_buffer,
                        },
                    },
                },
            },
        })

        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
        vim.keymap.set('n', '<leader>pg', builtin.git_files, {})
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
