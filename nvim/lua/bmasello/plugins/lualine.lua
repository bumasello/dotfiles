return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local lualine = require("lualine")
		local lazy_status = require("lazy.status") -- to configure lazy pending updates count

		local colors = {
			base03 = "#002b36",
			base02 = "#073642",
			base01 = "#586e75",
			base00 = "#657b83",
			base0 = "#839496",
			base1 = "#93a1a1",
			base2 = "#eee8d5",
			base3 = "#fdf6e3",
			yellow = "#b58900",
			orange = "#cb4b16",
			red = "#dc322f",
			magenta = "#d33682",
			violet = "#6c71c4",
			blue = "#268bd2",
			cyan = "#2aa198",
			green = "#859900",
		}

		local my_lualine_theme = {
			normal = {
				a = { bg = colors.base02, fg = colors.base3, gui = "bold" },
				b = { bg = colors.base03, fg = colors.base0 },
				c = { bg = colors.base03, fg = colors.base0 },
			},
			insert = {
				a = { bg = colors.base02, fg = colors.green, gui = "bold" },
				b = { bg = colors.base03, fg = colors.base0 },
				c = { bg = colors.base03, fg = colors.base0 },
			},
			visual = {
				a = { bg = colors.base02, fg = colors.blue, gui = "bold" },
				b = { bg = colors.base03, fg = colors.base0 },
				c = { bg = colors.base03, fg = colors.base0 },
			},
			command = {
				a = { bg = colors.base02, fg = colors.yellow, gui = "bold" },
				b = { bg = colors.base03, fg = colors.base0 },
				c = { bg = colors.base03, fg = colors.base0 },
			},
			replace = {
				a = { bg = colors.base02, fg = colors.red, gui = "bold" },
				b = { bg = colors.base03, fg = colors.base0 },
				c = { bg = colors.base03, fg = colors.base0 },
			},
			inactive = {
				a = { bg = colors.base01, fg = colors.base02, gui = "bold" },
				b = { bg = colors.base01, fg = colors.base02 },
				c = { bg = colors.base01, fg = colors.base02 },
			},
		}

		-- configure lualine with modified theme
		lualine.setup({
			options = {
				theme = my_lualine_theme,
			},
			sections = {
				lualine_x = {
					{
						lazy_status.updates,
						cond = lazy_status.has_updates,
						color = { fg = "#ff9e64" },
					},
					{ "encoding" },
					{ "fileformat" },
					{ "filetype" },
				},
			},
		})
	end,
}
