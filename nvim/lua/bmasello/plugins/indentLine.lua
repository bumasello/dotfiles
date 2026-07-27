return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	config = function()
		local highlight = {
			"RainbowDelimiterRed",
			"RainbowDelimiterOrange",
			"RainbowDelimiterYellow",
			"RainbowDelimiterGreen",
			"RainbowDelimiterCyan",
			"RainbowDelimiterBlue",
			"RainbowDelimiterViolet",
		}

		local hooks = require("ibl.hooks")

		-- redefine as cores aqui também, pra não depender da ordem
		-- de carregamento em relação ao plugin rainbow-delimiters
		hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
			vim.api.nvim_set_hl(0, "RainbowDelimiterRed", { fg = "#dc322f" })
			vim.api.nvim_set_hl(0, "RainbowDelimiterOrange", { fg = "#cb4b16" })
			vim.api.nvim_set_hl(0, "RainbowDelimiterYellow", { fg = "#b58900" })
			vim.api.nvim_set_hl(0, "RainbowDelimiterGreen", { fg = "#859900" })
			vim.api.nvim_set_hl(0, "RainbowDelimiterCyan", { fg = "#2aa198" })
			vim.api.nvim_set_hl(0, "RainbowDelimiterBlue", { fg = "#268bd2" })
			vim.api.nvim_set_hl(0, "RainbowDelimiterViolet", { fg = "#6c71c4" })
		end)

		require("ibl").setup({
			indent = { highlight = highlight },
			whitespace = {
				highlight = highlight,
				remove_blankline_trail = false,
			},
			scope = {
				enabled = true,
				highlight = highlight,
				show_start = true,
				show_end = false,
			},
		})

		hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
	end,
}
