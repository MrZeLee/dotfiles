return {
	"sindrets/diffview.nvim",
	dependencies = "nvim-lua/plenary.nvim",
	config = function()
		require("diffview").setup({
			diff_binaries = false,
			enhanced_diff_hl = false,
			git_cmd = { "git" },
			use_icons = true,
			show_help_hints = true,
			watch_index = true,
			icons = {
				folder_closed = "",
				folder_open = "",
			},
			signs = {
				fold_closed = "",
				fold_open = "",
				done = "✓",
			},
			view = {
				default = {
					layout = "diff2_horizontal",
					winbar_info = false,
				},
				merge_tool = {
					layout = "diff3_horizontal",
					disable_diagnostics = true,
					winbar_info = true,
				},
				file_history = {
					layout = "diff2_horizontal",
					winbar_info = false,
				},
			},
			file_panel = {
				listing_style = "tree",
				tree_options = {
					flatten_dirs = true,
					folder_statuses = "only_folded",
				},
				win_config = {
					position = "left",
					width = 35,
					win_opts = {}
				},
			},
			file_history_panel = {
				log_options = {
					git = {
						single_file = {
							diff_merges = "combined",
						},
						multi_file = {
							diff_merges = "first-parent",
						},
					},
				},
				win_config = {
					position = "bottom",
					height = 16,
					win_opts = {}
				},
			},
			commit_log_panel = {
				win_config = {
					win_opts = {},
				}
			},
			default_args = {
				DiffviewOpen = {},
				DiffviewFileHistory = {},
			},
			hooks = {
				diff_buf_read = function()
					-- Disable focus.nvim when diffview opens
					vim.cmd("FocusDisable")
				end,
			},
			keymaps = {
				disable_defaults = false,
				view = {
					{
						"n",
						"<tab>",
						require("diffview.actions").select_next_entry,
						{ desc = "Open the diff for the next file" }
					},
					{
						"n",
						"<s-tab>",
						require("diffview.actions").select_prev_entry,
						{ desc = "Open the diff for the previous file" }
					},
					{
						"n",
						"gf",
						require("diffview.actions").goto_file,
						{ desc = "Open the file in a new split in the previous tabpage" }
					},
					{
						"n",
						"<C-w><C-f>",
						require("diffview.actions").goto_file_split,
						{ desc = "Open the file in a new split" }
					},
					{
						"n",
						"<C-w>gf",
						require("diffview.actions").goto_file_tab,
						{ desc = "Open the file in a new tabpage" }
					},
					{
						"n",
						"<leader>e",
						require("diffview.actions").focus_files,
						{ desc = "Bring focus to the file panel" }
					},
					{
						"n",
						"<leader>b",
						require("diffview.actions").toggle_files,
						{ desc = "Toggle the file panel." }
					},
					{
						"n",
						"g<C-x>",
						require("diffview.actions").cycle_layout,
						{ desc = "Cycle through available layouts." }
					},
					{
						"n",
						"[x",
						require("diffview.actions").prev_conflict,
						{ desc = "In the merge-tool: jump to the previous conflict" }
					},
					{
						"n",
						"]x",
						require("diffview.actions").next_conflict,
						{ desc = "In the merge-tool: jump to the next conflict" }
					},
				},
				file_panel = {
					{
						"n",
						"j",
						require("diffview.actions").next_entry,
						{ desc = "Bring the cursor to the next file entry" }
					},
					{
						"n",
						"<down>",
						require("diffview.actions").next_entry,
						{ desc = "Bring the cursor to the next file entry" }
					},
					{
						"n",
						"k",
						require("diffview.actions").prev_entry,
						{ desc = "Bring the cursor to the previous file entry." }
					},
					{
						"n",
						"<up>",
						require("diffview.actions").prev_entry,
						{ desc = "Bring the cursor to the previous file entry." }
					},
					{
						"n",
						"<cr>",
						require("diffview.actions").select_entry,
						{ desc = "Open the diff for the selected entry." }
					},
					{
						"n",
						"o",
						require("diffview.actions").select_entry,
						{ desc = "Open the diff for the selected entry." }
					},
					{
						"n",
						"<2-LeftMouse>",
						require("diffview.actions").select_entry,
						{ desc = "Open the diff for the selected entry." }
					},
					{
						"n",
						"-",
						require("diffview.actions").toggle_stage_entry,
						{ desc = "Stage / unstage the selected entry." }
					},
					{
						"n",
						"S",
						require("diffview.actions").stage_all,
						{ desc = "Stage all entries." }
					},
					{
						"n",
						"U",
						require("diffview.actions").unstage_all,
						{ desc = "Unstage all entries." }
					},
					{
						"n",
						"X",
						require("diffview.actions").restore_entry,
						{ desc = "Restore entry to the state on the left side." }
					},
					{
						"n",
						"L",
						require("diffview.actions").open_commit_log,
						{ desc = "Open the commit log panel." }
					},
					{
						"n",
						"zo",
						require("diffview.actions").open_fold,
						{ desc = "Expand fold" }
					},
					{
						"n",
						"h",
						require("diffview.actions").close_fold,
						{ desc = "Collapse fold" }
					},
					{
						"n",
						"zc",
						require("diffview.actions").close_fold,
						{ desc = "Collapse fold" }
					},
					{
						"n",
						"za",
						require("diffview.actions").toggle_fold,
						{ desc = "Toggle fold" }
					},
					{
						"n",
						"zR",
						require("diffview.actions").open_all_folds,
						{ desc = "Expand all folds" }
					},
					{
						"n",
						"zM",
						require("diffview.actions").close_all_folds,
						{ desc = "Collapse all folds" }
					},
					{
						"n",
						"<c-b>",
						require("diffview.actions").scroll_view(-0.25),
						{ desc = "Scroll the view up" }
					},
					{
						"n",
						"<c-f>",
						require("diffview.actions").scroll_view(0.25),
						{ desc = "Scroll the view down" }
					},
					{
						"n",
						"<tab>",
						require("diffview.actions").select_next_entry,
						{ desc = "Open the diff for the next file" }
					},
					{
						"n",
						"<s-tab>",
						require("diffview.actions").select_prev_entry,
						{ desc = "Open the diff for the previous file" }
					},
					{
						"n",
						"gf",
						require("diffview.actions").goto_file,
						{ desc = "Open the file in a new split in the previous tabpage" }
					},
					{
						"n",
						"<C-w><C-f>",
						require("diffview.actions").goto_file_split,
						{ desc = "Open the file in a new split" }
					},
					{
						"n",
						"<C-w>gf",
						require("diffview.actions").goto_file_tab,
						{ desc = "Open the file in a new tabpage" }
					},
					{
						"n",
						"i",
						require("diffview.actions").listing_style,
						{ desc = "Toggle between 'list' and 'tree' views" }
					},
					{
						"n",
						"f",
						require("diffview.actions").toggle_flatten_dirs,
						{ desc = "Flatten empty subdirectories in tree listing style." }
					},
					{
						"n",
						"R",
						require("diffview.actions").refresh_files,
						{ desc = "Update stats and entries in the file list." }
					},
					{
						"n",
						"<leader>e",
						require("diffview.actions").focus_files,
						{ desc = "Bring focus to the file panel" }
					},
					{
						"n",
						"<leader>b",
						require("diffview.actions").toggle_files,
						{ desc = "Toggle the file panel" }
					},
					{
						"n",
						"g<C-x>",
						require("diffview.actions").cycle_layout,
						{ desc = "Cycle through available layouts." }
					},
					{
						"n",
						"[x",
						require("diffview.actions").prev_conflict,
						{ desc = "In the merge-tool: jump to the previous conflict" }
					},
					{
						"n",
						"]x",
						require("diffview.actions").next_conflict,
						{ desc = "In the merge-tool: jump to the next conflict" }
					},
				},
				file_history_panel = {
					{
						"n",
						"g!",
						require("diffview.actions").options,
						{ desc = "Open the option panel" }
					},
					{
						"n",
						"<C-A-d>",
						require("diffview.actions").open_in_diffview,
						{ desc = "Open the entry under the cursor in a diffview" }
					},
					{
						"n",
						"y",
						require("diffview.actions").copy_hash,
						{ desc = "Copy the commit hash of the entry under the cursor" }
					},
					{
						"n",
						"L",
						require("diffview.actions").open_commit_log,
						{ desc = "Show commit details" }
					},
					{
						"n",
						"zR",
						require("diffview.actions").open_all_folds,
						{ desc = "Expand all folds" }
					},
					{
						"n",
						"zM",
						require("diffview.actions").close_all_folds,
						{ desc = "Collapse all folds" }
					},
					{
						"n",
						"j",
						require("diffview.actions").next_entry,
						{ desc = "Bring the cursor to the next file entry" }
					},
					{
						"n",
						"<down>",
						require("diffview.actions").next_entry,
						{ desc = "Bring the cursor to the next file entry" }
					},
					{
						"n",
						"k",
						require("diffview.actions").prev_entry,
						{ desc = "Bring the cursor to the previous file entry." }
					},
					{
						"n",
						"<up>",
						require("diffview.actions").prev_entry,
						{ desc = "Bring the cursor to the previous file entry." }
					},
					{
						"n",
						"<cr>",
						require("diffview.actions").select_entry,
						{ desc = "Open the diff for the selected entry." }
					},
					{
						"n",
						"o",
						require("diffview.actions").select_entry,
						{ desc = "Open the diff for the selected entry." }
					},
					{
						"n",
						"<2-LeftMouse>",
						require("diffview.actions").select_entry,
						{ desc = "Open the diff for the selected entry." }
					},
					{
						"n",
						"<c-b>",
						require("diffview.actions").scroll_view(-0.25),
						{ desc = "Scroll the view up" }
					},
					{
						"n",
						"<c-f>",
						require("diffview.actions").scroll_view(0.25),
						{ desc = "Scroll the view down" }
					},
					{
						"n",
						"<tab>",
						require("diffview.actions").select_next_entry,
						{ desc = "Open the diff for the next file" }
					},
					{
						"n",
						"<s-tab>",
						require("diffview.actions").select_prev_entry,
						{ desc = "Open the diff for the previous file" }
					},
					{
						"n",
						"gf",
						require("diffview.actions").goto_file,
						{ desc = "Open the file in a new split in the previous tabpage" }
					},
					{
						"n",
						"<C-w><C-f>",
						require("diffview.actions").goto_file_split,
						{ desc = "Open the file in a new split" }
					},
					{
						"n",
						"<C-w>gf",
						require("diffview.actions").goto_file_tab,
						{ desc = "Open the file in a new tabpage" }
					},
					{
						"n",
						"<leader>e",
						require("diffview.actions").focus_files,
						{ desc = "Bring focus to the file panel" }
					},
					{
						"n",
						"<leader>b",
						require("diffview.actions").toggle_files,
						{ desc = "Toggle the file panel." }
					},
					{
						"n",
						"g<C-x>",
						require("diffview.actions").cycle_layout,
						{ desc = "Cycle through available layouts." }
					},
				},
				option_panel = {
					{
						"n",
						"<tab>",
						require("diffview.actions").select_entry,
						{ desc = "Change the current option" }
					},
					{
						"n",
						"q",
						require("diffview.actions").close,
						{ desc = "Close the panel" }
					},
					{
						"n",
						"<c-c>",
						require("diffview.actions").close,
						{ desc = "Close the panel" }
					},
				},
				help_panel = {
					{
						"n",
						"q",
						require("diffview.actions").close,
						{ desc = "Close help menu" }
					},
					{
						"n",
						"<esc>",
						require("diffview.actions").close,
						{ desc = "Close help menu" }
					},
				},
			},
		})

		-- Add keymaps
		vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<CR>", { desc = "Open Diffview" })
		vim.keymap.set("n", "<leader>gD", "<cmd>DiffviewClose<CR>", { desc = "Close Diffview" })
		vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory<CR>", { desc = "File History" })
		vim.keymap.set("n", "<leader>gH", "<cmd>DiffviewFileHistory %<CR>", { desc = "Current File History" })

		-- Auto-enable focus.nvim when diffview closes
		vim.api.nvim_create_autocmd("User", {
			pattern = "DiffviewViewClosed",
			callback = function()
				vim.cmd("FocusEnable")
			end,
		})

		-- Register with which-key if available
		local ok, wk = pcall(require, "which-key")
		if ok then
			wk.add({
				{ "<leader>gd", desc = "Open Diffview" },
				{ "<leader>gD", desc = "Close Diffview" },
				{ "<leader>gh", desc = "File History" },
				{ "<leader>gH", desc = "Current File History" },
			})
		end
	end,
}