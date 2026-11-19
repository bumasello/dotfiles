return {
	"s1n7ax/nvim-window-picker",
	name = "window-picker",
	version = "2.*",
	lazy = true,
	opts = {
		-- big floating letter in the middle of each window
		hint = "floating-big-letter",
		selection_chars = "ASDFJKL",
		filter_rules = {
			autoselect_one = true,
			include_current_win = false,
			bo = {
				filetype = { "NvimTree", "notify", "qf", "diff", "fugitive", "fugitiveblame" },
				buftype = { "nofile", "terminal", "help" },
			},
		},
	},
}
