return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		-- Set header

		local header_highlight = "MoonflyWhite"
		local button_highlight = "MoonflySky"

		dashboard.section.header.val = {
			"                                       ",
			"	 ███╗   ███╗ █████╗ ███████╗███████╗  ",
			"  ████╗ ████║██╔══██╗╚══███╔╝██╔════╝  ",
			"  ██╔████╔██║███████║  ███╔╝ █████╗    ",
			"  ██║╚██╔╝██║██╔══██║ ███╔╝  ██╔══╝    ",
			"  ██║ ╚═╝ ██║██║  ██║███████╗███████╗  ",
			"  ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝  ",
			"                                       ",
		}

		dashboard.section.header.opts = { hl = header_highlight, position = "center" }
		dashboard.section.buttons.opts = { hl_shortcut = button_highlight }
		dashboard.section.footer.opts = {
			position = "center",
			hl = "button_highlight",
		}

		-- Set menu
		dashboard.section.buttons.val = {
			dashboard.button("e", "  > New File", "<cmd>ene<CR>"),
			dashboard.button("SPC ee", "  > Toggle file explorer", "<cmd>NvimTreeToggle<CR>"),
			dashboard.button("SPC ff", "󰱼  > Find File", "<cmd>Telescope find_files<CR>"),
			dashboard.button("SPC fs", "  > Find Word", "<cmd>Telescope live_grep<CR>"),
			dashboard.button("SPC wr", "󰁯  > Restore Session For Current Directory", "<cmd>SessionRestore<CR>"),
			dashboard.button("q", "  > Quit NVIM", "<cmd>qa<CR>"),
		}

		dashboard.section.footer.val = "A jornada do desenvolvedor é marcada por desafios e otimizações."

		-- Send config to alpha
		alpha.setup(dashboard.opts)

		-- Disable folding on alpha buffer
		vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
	end,
}
