local function attach(opts)
    --vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    --vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    --vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    --vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    --vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    --vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    -- Fix Control h that is also used to move left in nvim panes
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
    vim.keymap.set("n", "<leader>gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "<leader>gi", function() vim.lsp.buf.implementation() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("n", "<leader>gr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>e", function() vim.diagnostic.open_float() end, opts)
end
return {

    "neovim/nvim-lspconfig",
    dependencies = {
        {
            "williamboman/mason.nvim",
            tag = 'v1.10.0',
        },
         {
            "williamboman/mason-lspconfig.nvim",
            tag = 'v1.30.0',
        }
    },

    config = function ()
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "rust_analyzer",
                "tsserver",
                "ansiblels",
                "jdtls",
            },
            handlers = {
                function (server_name)
                    -- print("setting up", server_name)
                    require("lspconfig")[server_name].setup {}
                end,
            }
        })

        local lspconfig = require("lspconfig")

        lspconfig.lua_ls.setup {
            settings = {
                Lua = {
                    diagnostics = {
                        globals = {"vim"},
                    },
                },
            },
        }

        lspconfig.tsserver.setup {}
        lspconfig.ansiblels.setup {}
        lspconfig.rust_analyzer.setup {}

        attach({noremap = true, silent = true})
    end
}
