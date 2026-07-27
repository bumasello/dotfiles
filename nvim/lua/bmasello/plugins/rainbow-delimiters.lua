return {
	"HiPhish/rainbow-delimiters.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("rainbow-delimiters.setup").setup({
			strategy = {
				[""] = "rainbow-delimiters.strategy.global",
			},
			query = {
				[""] = "rainbow-delimiters",
				lua = "rainbow-blocks",
			},
		})

		-- Define as cores (a maioria dos colorschemes não vem com isso,
		-- então precisa ser feito manualmente e reaplicado sempre que
		-- o colorscheme for (re)carregado)
		local function set_rainbow_colors()
			vim.api.nvim_set_hl(0, "RainbowDelimiterRed", { fg = "#dc322f" })
			vim.api.nvim_set_hl(0, "RainbowDelimiterOrange", { fg = "#cb4b16" })
			vim.api.nvim_set_hl(0, "RainbowDelimiterYellow", { fg = "#b58900" })
			vim.api.nvim_set_hl(0, "RainbowDelimiterGreen", { fg = "#859900" })
			vim.api.nvim_set_hl(0, "RainbowDelimiterCyan", { fg = "#2aa198" })
			vim.api.nvim_set_hl(0, "RainbowDelimiterBlue", { fg = "#268bd2" })
			vim.api.nvim_set_hl(0, "RainbowDelimiterViolet", { fg = "#6c71c4" })
		end

		set_rainbow_colors()

		vim.api.nvim_create_autocmd("ColorScheme", {
			callback = set_rainbow_colors,
		})
	end,
}
