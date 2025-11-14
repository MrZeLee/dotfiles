return {
	"akinsho/git-conflict.nvim",
	version = "*",
	config = function()
		require("git-conflict").setup({
			default_mappings = true, -- disable buffer local mapping created by this plugin
			default_commands = true, -- disable commands created by this plugin
			disable_diagnostics = false, -- This will disable the diagnostics in a buffer whilst it is conflicted
			list_opener = "copen", -- command or function to open the conflicts list
			highlights = { -- They must have background color, otherwise the default color will be used
				incoming = "DiffAdd",
				current = "DiffText",
			},
		})

		-- Default mappings:
		-- co — choose ours
		-- ct — choose theirs
		-- cb — choose both
		-- c0 — choose none
		-- ]x — move to previous conflict
		-- [x — move to next conflict

		-- Additional keymaps
		vim.keymap.set("n", "<leader>gco", "<cmd>GitConflictChooseOurs<CR>", { desc = "Choose ours (current)" })
		vim.keymap.set("n", "<leader>gct", "<cmd>GitConflictChooseTheirs<CR>", { desc = "Choose theirs (incoming)" })
		vim.keymap.set("n", "<leader>gcb", "<cmd>GitConflictChooseBoth<CR>", { desc = "Choose both" })
		vim.keymap.set("n", "<leader>gc0", "<cmd>GitConflictChooseNone<CR>", { desc = "Choose none" })
		vim.keymap.set("n", "<leader>gcl", "<cmd>GitConflictListQf<CR>", { desc = "List conflicts in quickfix" })

		-- Register with which-key
		local wk = require("which-key")
		wk.add({
			{ "<leader>gc", group = "Git Conflict" },
			{ "<leader>gco", desc = "Choose ours (current)" },
			{ "<leader>gct", desc = "Choose theirs (incoming)" },
			{ "<leader>gcb", desc = "Choose both" },
			{ "<leader>gc0", desc = "Choose none" },
			{ "<leader>gcl", desc = "List conflicts in quickfix" },
			{ "co", desc = "Choose ours" },
			{ "ct", desc = "Choose theirs" },
			{ "cb", desc = "Choose both" },
			{ "c0", desc = "Choose none" },
			{ "]x", desc = "Next conflict" },
			{ "[x", desc = "Previous conflict" },
		})
	end,
}
