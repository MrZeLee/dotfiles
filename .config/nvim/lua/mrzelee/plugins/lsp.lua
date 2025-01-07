return {

    "neovim/nvim-lspconfig",
    tag = 'v1.0.0',
    dependencies = {
        {
            "williamboman/mason.nvim",
            tag = 'v1.10.0',
        },
        {
            "williamboman/mason-lspconfig.nvim",
            tag = 'v1.31.0',
        },
        {
            "hrsh7th/cmp-nvim-lsp",
        },
        {
            "hrsh7th/nvim-cmp",
        },
        {
            "hrsh7th/cmp-buffer",
        },
        {
            "hrsh7th/cmp-path",
        },
    },

    config = function()
        local function is_nixos()
            -- Check if the OS is NixOS by inspecting /etc/os-release
            local f = io.popen("grep '^ID=' /etc/os-release")
            if not f then return false end
            local os_id = f:read("*a") or ""
            f:close()
            return os_id:match("ID=nixos") ~= nil
        end

        -- Define different LSP servers for NixOS and other systems
        local ensure_installed = is_nixos() and {
            "rust_analyzer",
            "ts_ls",
            "ansiblels",
            "jdtls",
            "rnix",
        } or {
            "lua_ls",
            "rust_analyzer",
            "ts_ls",
            "ansiblels",
            "jdtls",
            "rnix",
        }

        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = ensure_installed,
            handlers = {
                function(server_name)
                    if is_nixos() then
                        -- NixOS-specific setup
                        if server_name == "lua_ls" then
                            require("lspconfig").lua_ls.setup {
                                cmd = { "lua-language-server" }, -- Ensure Nix-installed binary is used
                            }
                        -- elseif server_name == "sss" then
                        --     -- Custom setup for "sss" on NixOS
                        --     require("lspconfig").sss.setup {
                        --         cmd = { "path/to/sss" }, -- Adjust for NixOS-specific path
                        --     }
                        else
                            -- Default setup for other servers on NixOS
                            require("lspconfig")[server_name].setup {}
                        end
                    else
                        -- Default setup for all servers on non-NixOS systems
                        require("lspconfig")[server_name].setup {}
                    end
                end,
            }
        })

        local lspconfig = require("lspconfig")

        -- Add cmp_nvim_lsp capabilities settings to lspconfig
        -- This should be executed before you configure any language server
        local lspconfig_defaults = lspconfig.util.default_config
        lspconfig_defaults.capabilities = vim.tbl_deep_extend(
            'force',
            lspconfig_defaults.capabilities,
            require('cmp_nvim_lsp').default_capabilities()
        )

        lspconfig.lua_ls.setup {
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim" },
                    },
                },
            },
        }

        -- Reserve a space in the gutter
        -- This will avoid an annoying layout shift in the screen
        vim.opt.signcolumn = 'yes'

        -- This is where you enable features that only work
        -- if there is a language server active in the file
        vim.api.nvim_create_autocmd('LspAttach', {
            desc = 'LSP actions',
            callback = function(event)
                local opts = { buffer = event.buf }

                vim.keymap.set('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
                vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
                vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
                vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
                vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
                vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
                vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
                vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
                vim.keymap.set("n", "<leader>rn", '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
                vim.keymap.set({ 'n', 'x' }, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
                vim.keymap.set("n", "<leader>vca", '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
                vim.keymap.set("n", "<leader>vws", '<cmd>lua vim.lsp.buf.workspace_symbol()<cr>', opts)
                -- Fix Control h that is also used to move left in nvim panes
                vim.keymap.set("i", "<C-h>", '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)

                -- vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
                -- vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
                -- vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
                -- vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
                -- vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
                -- vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
                -- vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
                -- vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
                -- vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
            end,
        })

        local cmp = require('cmp')

        cmp.setup({
            preselect = 'item',
            completion = {
                -- autocomplete = false,
                completeopt = 'menu,menuone,noinsert'
            },
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
            sources = {
                { name = 'nvim_lsp' },
                { name = 'buffer' },
                { name = 'path' },
            },
            mapping = cmp.mapping.preset.insert({
                -- Navigate between completion items
                ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = 'select' }),
                ['<C-n>'] = cmp.mapping.select_next_item({ behavior = 'select' }),
                -- Simple tab complete
                ['<Tab>'] = cmp.mapping(function(fallback)
                    local col = vim.fn.col('.') - 1

                    if cmp.visible() then
                        cmp.select_next_item({ behavior = 'select' })
                    elseif col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
                        fallback()
                    else
                        cmp.complete()
                    end
                end, { 'i', 's' }),

                -- Go to previous item
                ['<S-Tab>'] = cmp.mapping.select_prev_item({ behavior = 'select' }),

                -- `Enter` key to confirm completion
                ['<CR>'] = cmp.mapping.confirm({ select = false }),
                ['<C-y>'] = cmp.mapping.confirm({ select = true }),

                -- Ctrl+Space to trigger completion menu
                ['<C-Space>'] = cmp.mapping.complete(),

                -- Scroll up and down in the completion documentation
                ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                ['<C-d>'] = cmp.mapping.scroll_docs(4),
            }),
            snippet = {
                expand = function(args)
                    vim.snippet.expand(args.body)
                end,
            },
        })

        vim.api.nvim_create_autocmd('LspAttach', {
            callback = function(event)
                local opts = { buffer = event.buf }

                vim.keymap.set({ 'n', 'x' }, 'gq', function()
                    vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
                end, opts)
            end
        })

        vim.diagnostic.config({
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = '✘',
                    [vim.diagnostic.severity.WARN] = '▲',
                    [vim.diagnostic.severity.HINT] = '⚑',
                    [vim.diagnostic.severity.INFO] = '»',
                },
            },
        })

        -- lspconfig.ts_ls.setup {}
        -- lspconfig.ansiblels.setup {}
        -- lspconfig.rust_analyzer.setup {}

        -- attach({noremap = true, silent = true})
    end
}
