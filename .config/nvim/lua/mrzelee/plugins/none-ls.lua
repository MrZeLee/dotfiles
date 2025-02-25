return {
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

			"pylint", -- python linter
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
			-- add package.json as identifier for root (for typescript monorepos)
			root_dir = null_ls_utils.root_pattern(".null-ls-root", "Makefile", ".git", "package.json"),
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
				formatting.prettier.with({
					disabled_filetypes = { "markdown" },
				}),
				formatting.stylua, -- lua formatter
				formatting.isort,
				formatting.black,
				formatting.shfmt,
				diagnostics.pylint,
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
}
