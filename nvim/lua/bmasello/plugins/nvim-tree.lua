return {
	"nvim-tree/nvim-tree.lua",
	dependencies = { "nvim-tree/nvim-web-devicons", "s1n7ax/nvim-window-picker" },
	config = function()
		local nvimtree = require("nvim-tree")

		-- recommended settings from nvim-tree documentation
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		-- change color for arrows in tree to light blue
		vim.cmd([[ highlight NvimTreeFolderArrowClosed guifg=#3FC5FF ]])
		vim.cmd([[ highlight NvimTreeFolderArrowOpen guifg=#3FC5FF ]])

		-- configure nvim-tree
		nvimtree.setup({
			view = {
				width = { min = 35, max = 60 },
				side = "right",
				relativenumber = true,
			},
			-- change folder arrow icons
			renderer = {
				indent_markers = {
					enable = true,
				},
				icons = {
					glyphs = {
						folder = {
							arrow_closed = "", -- arrow when folder is closed
							arrow_open = "", -- arrow when folder is open
						},
					},
				},
			},
			-- window_picker asks which split to open the file in
			-- when there is more than one window
			actions = {
				open_file = {
					window_picker = {
						enable = true,
						-- floating letters from nvim-window-picker instead of the statusline
						picker = function()
							-- only the tree is open (e.g. `nvim .`): return -1 so
							-- nvim-tree opens the file in a new split by itself
							local has_target = vim.iter(vim.api.nvim_tabpage_list_wins(0)):any(function(win)
								local buf = vim.api.nvim_win_get_buf(win)
								return vim.api.nvim_win_get_config(win).relative == ""
									and vim.bo[buf].filetype ~= "NvimTree"
									and not vim.tbl_contains({ "nofile", "terminal", "help" }, vim.bo[buf].buftype)
							end)
							if not has_target then
								return -1
							end
							return require("window-picker").pick_window()
						end,
					},
				},
			},
			filters = {
				custom = { ".DS_Store" },
			},
			git = {
				ignore = false,
			},
		})

		-- set keymaps
		local keymap = vim.keymap -- for conciseness

		keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" }) -- toggle file explorer
		keymap.set(
			"n",
			"<leader>ef",
			"<cmd>NvimTreeFindFileToggle<CR>",
			{ desc = "Toggle file explorer on current file" }
		) -- toggle file explorer on current file
		keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" }) -- collapse file explorer
		keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" }) -- refresh file explorer
	end,
}
