return {
	{
		"neovim/nvim-lspconfig",
		version = "*",
		dependencies = {
			{
				"williamboman/mason.nvim",
				version = "*",
			},
			{
				"williamboman/mason-lspconfig.nvim",
				version = "*",
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
				"nil_ls",
				"jsonls",
				"bashls",
				"pyright",
        "jdtls",
			}

			local not_install_nix = {
				"lua_ls",
				"marksman",
			}

			if not IsNixos then
				vim.list_extend(ensure_installed, not_install_nix)
			end

      local mason_lspconfig = require("mason-lspconfig")

			require("mason").setup()
			mason_lspconfig.setup({
				automatic_enable = {
          exclude = {
            "jdtls",
          }
        },
				-- Whether servers that are set up (via lspconfig) should be automatically installed if they're not already installed.
				-- This setting has no relation with the `ensure_installed` setting.
				-- Can either be:
				--   - false: Servers are not automatically installed.
				--   - true: All servers set up via lspconfig are automatically installed.
				--   - { exclude: string[] }: All servers set up via lspconfig, except the ones provided in the list, are automatically installed.
				--       Example: automatic_installation = { exclude = { "rust_analyzer", "solargraph" } }
				---@type boolean
				automatic_installation = false,
				-- A list of servers to automatically install if they're not already installed. Example: { "rust_analyzer@nightly", "lua_ls" }
				-- This setting has no relation with the `automatic_installation` setting.
				---@type string[]
				ensure_installed = ensure_installed,
				-- See `:h mason-lspconfig.setup_handlers()`
				---@type table<string, fun(server_name: string)>?
        ---TODO: I think this handlers are obsulete
				handlers = {
					function(server_name)
            print("🔥 Server Name: ", server_name)
						if IsNixos then
							-- NixOS-specific setup
							if server_name == "lua_ls" then
                -- where Mason put lombok.jar alongside jdtls
								require("lspconfig").lua_ls.setup({

									cmd = { "lua-language-server" }, -- Ensure Nix-installed binary is used
								})
                return
							elseif vim.tbl_contains(not_install_nix, server_name) then
								require("lspconfig")[server_name].setup({
									cmd = { server_name },
								})
                return
							end
            end
            -- Default setup for all servers on non-NixOS systems
            require("lspconfig")[server_name].setup({})
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

			if IsNixos then
				lspconfig.marksman.setup({})
			end

      -- TODO: add a callback function so every time I enter a java file it
      -- works well
      local util = lspconfig.util

      -- helper to find the git root using vim.fs
      local function find_git_root(startpath)
        local git_dir = vim.fs.find(".git", { path = startpath, upward = true })[1]
        return git_dir and vim.fs.dirname(git_dir)
      end

      -- in your handler:
      local fname = vim.api.nvim_buf_get_name(0)

      local root_dir = util.root_pattern("pom.xml", "build.gradle")(fname)
      or find_git_root(fname)
      or vim.loop.cwd()

      local lombok_path = vim.fn.stdpath('data') .. '/mason/packages/jdtls/lombok.jar'
      lspconfig.jdtls.setup({
        cmd = {
          vim.fn.exepath("jdtls"),
          "--jvm-arg=-javaagent:" .. lombok_path,
          "-configuration", vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fs.basename(root_dir) .. "/config",
          "-data",          vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fs.basename(root_dir) .. "/workspace",
        },
        settings  = {
          java = {
            inlayHints = { parameterNames = { enabled = "all" } },
          },
        },
        init_options = {
          bundles = {},  -- add your debug/test bundles here if you need them
        },
        capabilities = vim.lsp.protocol.make_client_capabilities(),
      })

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
					-- [d  → diagnóstico anterior (count negativo)
					vim.keymap.set("n", "[d", function()
						vim.diagnostic.jump({
							count = -vim.v.count1, -- usa o count digitado; -1 por padrão
							float = true, -- abre o pop-up com a mensagem
						})
					end, {
						desc = "Go to previous diagnostic",
						unpack(opts),
					})
					-- ]d  → próximo diagnóstico (count positivo)
					vim.keymap.set("n", "]d", function()
						vim.diagnostic.jump({
							count = vim.v.count1, -- +1 por padrão
							float = true,
						})
					end, {
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
						vim.lsp.buf.format({
							-- choose the client explicitly
							filter = function(client)
								return client.name == "null-ls"
							end,
							async = false,
							timeout_ms = 10000,
						})
					end, {
						buffer = event.buf,
						noremap = true,
						silent = true,
						desc = "Format the file with Prettier",
					})
					-- vim.keymap.set({ "n", "x" }, "gq", function()
					-- 	vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
					-- end, {
					-- 	desc = "Format the file",
					-- 	unpack(opts),
					-- })
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
		version = "*",
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
		version = "*",
		opts = function(_, opts)
			opts.sources = opts.sources or {}
			table.insert(opts.sources, {
				name = "lazydev",
				group_index = 0, -- set group index to 0 to skip loading LuaLS completions
			})
		end,
	},
	{
		"nvimtools/none-ls.nvim", -- configure formatters & linters
		lazy = true,
		event = { "BufReadPre", "BufNewFile" }, -- to enable uncomment this
		dependencies = {
			"jay-babu/mason-null-ls.nvim",
		},
		config = function()
			local mason_null_ls = require("mason-null-ls")
			local null_ls = require("null-ls")
			local null_ls_utils = require("null-ls.utils")

			local ensure_installed = {
				-- "prettierd", -- prettierd formatter
				"prettier",
				"black", -- python formatter
				"shfmt", -- sh formatter
			}

			local not_install_nix = {
				"stylua",
			}

			local not_install_darwin = {
				"alejandra",
			}

			if not IsNixos then
				vim.list_extend(ensure_installed, not_install_nix)
			end

			if not IsDarwin then
				vim.list_extend(ensure_installed, not_install_darwin)
			end

			mason_null_ls.setup({
				ensure_installed = ensure_installed,
			})

			-- for conciseness
			local formatting = null_ls.builtins.formatting -- to setup formatters
			local diagnostics = null_ls.builtins.diagnostics -- to setup linters

			-- to setup format on save
			-- local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

			-- configure null_ls
			null_ls.setup({
				-- debug = true,
				-- add package.json as identifier for root (for typescript monorepos)
				root_dir = function(fname)
					return null_ls_utils.root_pattern(".null-ls-root", "Makefile", ".git", "package.json")(fname)
						or vim.fn.getcwd() -- fallback to CWD
				end,
				-- root_dir = null_ls_utils.root_pattern(".null-ls-root", "Makefile", ".git", "package.json"),
				-- setup formatters & linters
				sources = {
					--  to disable file types use
					--  "formatting.prettier.with({disabled_filetypes: {}})" (see null-ls docs)
					-- formatting.prettier.with({
					--   extra_filetypes = { "svelte" },
					-- }), -- js/ts formatter
					formatting.alejandra,
					formatting.prettier.with({
						filetypes = { "markdown" },
						extra_args = { "--prose-wrap", "always", "--print-width", "80" },
					}),
					-- formatting.prettier.with({
					-- 	disabled_filetypes = { "markdown" },
					-- }),
					formatting.stylua, -- lua formatter
					formatting.isort,
					formatting.black,
					formatting.shfmt,
          formatting.xmllint,
				},
				-- configure format on save
				-- on_attach = function(current_client, bufnr)
				-- 	if current_client.supports_method("textDocument/formatting") then
				-- 		vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
				-- 		vim.api.nvim_create_autocmd("BufWritePre", {
				-- 			group = augroup,
				-- 			buffer = bufnr,
				-- 			callback = function()
				-- 				vim.lsp.buf.format({
				-- 					filter = function(client)
				-- 						--  only use null-ls for formatting instead of lsp server
				-- 						return client.name == "null-ls"
				-- 					end,
				-- 					bufnr = bufnr,
				-- 				})
				-- 			end,
				-- 		})
				-- 	end
				-- end,
			})
		end,
	},
}
