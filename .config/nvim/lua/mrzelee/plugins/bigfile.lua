return {
	"LunarVim/bigfile.nvim",
	enabled = false,
	event = "BufReadPre",
	opts = {
		filesize = 2,
	},
  config = function (_, opts)
    require('bigfile').setup(opts)
  end
}
