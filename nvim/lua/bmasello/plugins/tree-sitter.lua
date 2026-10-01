return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	build = ":TSUpdate",
	config = function()
		local ensure_installed = {
			"c",
			"lua",
			"vim",
			"vimdoc",
			"query",
			"elixir",
			"heex",
			"javascript",
			"typescript",
			"tsx",
			"python",
			"rust",
			"c_sharp",
			"html",
			"pug",
			"css",
			"json",
			"yaml",
			"toml",
			"bash",
			"markdown",
			"markdown_inline",
			"graphql",
			"svelte",
		}

		require("nvim-treesitter").setup()
		require("nvim-treesitter").install(ensure_installed)

		-- nome do parser nem sempre é o filetype (c_sharp → cs, tsx → typescriptreact)
		local filetypes = {}
		for _, lang in ipairs(ensure_installed) do
			vim.list_extend(filetypes, vim.treesitter.language.get_filetypes(lang))
		end

		vim.api.nvim_create_autocmd("FileType", {
			pattern = filetypes,
			callback = function()
				vim.treesitter.start()
				vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
