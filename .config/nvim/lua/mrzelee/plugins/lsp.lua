return {
	{

		"neovim/nvim-lspconfig",
		tag = "v1.0.0",
		dependencies = {
			{
				"williamboman/mason.nvim",
				tag = "v1.11.0",
			},
			{
				"williamboman/mason-lspconfig.nvim",
				tag = "v1.32.0",
			},
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
		},

		config = function()
			-- Define different LSP servers for NixOS and other systems
			local ensure_installed = {
				"rust_analyzer",
				"ts_ls",
				"ansiblels",
				"jdtls",
				"rnix",
				"jsonls",
				"bashls",
			}

			local not_install_nix = {
				"lua_ls",
				"marksman",
			}

			if not IsNixos() then
				vim.list_extend(ensure_installed, not_install_nix)
			end

			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = ensure_installed,
				handlers = {
					function(server_name)
						if IsNixos() then
							-- NixOS-specific setup
							if server_name == "lua_ls" then
								require("lspconfig").lua_ls.setup({
									cmd = { "lua-language-server" }, -- Ensure Nix-installed binary is used
								})
							elseif vim.tbl_contains(not_install_nix, server_name) then
								require("lspconfig")[server_name].setup({
									cmd = { server_name },
								})
							else
								-- Default setup for other servers on NixOS
								require("lspconfig")[server_name].setup({})
							end
						else
							-- Default setup for all servers on non-NixOS systems
							require("lspconfig")[server_name].setup({})
						end
					end,
				},
			})

			local lspconfig = require("lspconfig")

			-- Add cmp_nvim_lsp capabilities settings to lspconfig
			-- This should be executed before you configure any language server
			local lspconfig_defaults = lspconfig.util.default_config
			lspconfig_defaults.capabilities = vim.tbl_deep_extend(
				"force",
				lspconfig_defaults.capabilities,
				require("cmp_nvim_lsp").default_capabilities()
			)

			lspconfig.lua_ls.setup({
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
					},
				},
			})

			lspconfig.marksman.setup({})

			-- Reserve a space in the gutter
			-- This will avoid an annoying layout shift in the screen
			vim.opt.signcolumn = "yes"

			-- This is where you enable features that only work
			-- if there is a language server active in the file
			vim.api.nvim_create_autocmd("LspAttach", {
				desc = "LSP actions",
				callback = function(event)
					local opts = { buffer = event.buf, noremap = true, silent = true }

					-- Diagnostics
					vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, {
						desc = "Show diagnostics in floating window",
						unpack(opts),
					})
					vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, {
						desc = "Go to previous diagnostic",
						unpack(opts),
					})
					vim.keymap.set("n", "]d", vim.diagnostic.goto_next, {
						desc = "Go to next diagnostic",
						unpack(opts),
					})

					-- LSP navigation and info
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, {
						desc = "Go to definition",
						unpack(opts),
					})
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, {
						desc = "Go to implementation",
						unpack(opts),
					})
					vim.keymap.set("n", "go", vim.lsp.buf.type_definition, {
						desc = "Go to type definition",
						unpack(opts),
					})
					vim.keymap.set("n", "gr", vim.lsp.buf.references, {
						desc = "Show references",
						unpack(opts),
					})
					vim.keymap.set("n", "K", vim.lsp.buf.hover, {
						desc = "Show hover documentation",
						unpack(opts),
					})
					vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, {
						desc = "Show signature help",
						unpack(opts),
					})

					-- Code actions
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {
						desc = "Rename symbol",
						unpack(opts),
					})
					vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {
						desc = "Code actions",
						unpack(opts),
					})
					vim.keymap.set("n", "<leader>ws", vim.lsp.buf.workspace_symbol, {
						desc = "Search workspace symbols",
						unpack(opts),
					})
					vim.keymap.set({ "n", "x" }, "<F3>", function()
						vim.lsp.buf.format({ async = true })
					end, {
						desc = "Format code",
						unpack(opts),
					})

					-- Signature help in insert mode
					-- Fixed Control h that is also used to move left in nvim panes
					vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, {
						desc = "Show signature help",
						unpack(opts),
					})
					vim.keymap.set({ "n", "x" }, "gq", function()
						vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
					end, {
						desc = "Format the file",
						unpack(opts),
					})
				end,
			})

			local wk = require("which-key")

			wk.add({
				{ "<F3>", desc = "Format code" },
				{ "<leader>ca", desc = "Code actions" },
				{ "<leader>e", desc = "Show diagnostics in floating window" },
				{ "<leader>rn", desc = "Rename symbol" },
				{ "<leader>ws", desc = "Search workspace symbols" },
				{ "K", desc = "Show hover documentation" },
				{ "[d", desc = "Go to previous diagnostic" },
				{ "]d", desc = "Go to next diagnostic" },
				{ "gd", desc = "Go to definition" },
				{ "gi", desc = "Go to implementation" },
				{ "go", desc = "Go to type definition" },
				{ "gr", desc = "Show references" },
				{ "gs", desc = "Show signature help" },
				{ "gq", desc = "Format the file" },
			})

			local cmp = require("cmp")

			cmp.setup({
				preselect = "item",
				completion = {
					-- autocomplete = false,
					completeopt = "menu,menuone,noinsert",
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				sources = {
					{ name = "nvim_lsp" },
					{ name = "buffer" },
					{ name = "path" },
				},
				mapping = cmp.mapping.preset.insert({
					-- Navigate between completion items
					["<C-p>"] = cmp.mapping.select_prev_item({ behavior = "select" }),
					["<C-n>"] = cmp.mapping.select_next_item({ behavior = "select" }),
					-- Simple tab complete
					["<Tab>"] = cmp.mapping(function(fallback)
						local col = vim.fn.col(".") - 1

						if cmp.visible() then
							cmp.select_next_item({ behavior = "select" })
						elseif col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
							fallback()
						else
							cmp.complete()
						end
					end, { "i", "s" }),

					-- Go to previous item
					["<S-Tab>"] = cmp.mapping.select_prev_item({ behavior = "select" }),

					-- `Enter` key to confirm completion
					-- ['<CR>'] = cmp.mapping.confirm({ select = false }),
					["<C-y>"] = cmp.mapping.confirm({ select = true }),

					-- Ctrl+Space to trigger completion menu
					["<C-Space>"] = cmp.mapping.complete(),

					-- Scroll up and down in the completion documentation
					["<C-u>"] = cmp.mapping.scroll_docs(-4),
					["<C-d>"] = cmp.mapping.scroll_docs(4),
				}),
				snippet = {
					expand = function(args)
						vim.snippet.expand(args.body)
					end,
				},
			})

			vim.diagnostic.config({
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = "✘",
						[vim.diagnostic.severity.WARN] = "▲",
						[vim.diagnostic.severity.HINT] = "⚑",
						[vim.diagnostic.severity.INFO] = "»",
					},
				},
			})
		end,
	},
	{
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				-- See the configuration section for more details
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				-- Only load the telescope library when the `telescope.nvim` global is found
				{ path = "telescope.nvim", words = { "telescope" } },
			},
		},
	},
	{ -- optional cmp completion source for require statements and module annotations
		"hrsh7th/nvim-cmp",
		opts = function(_, opts)
			opts.sources = opts.sources or {}
			table.insert(opts.sources, {
				name = "lazydev",
				group_index = 0, -- set group index to 0 to skip loading LuaLS completions
			})
		end,
	}
}
