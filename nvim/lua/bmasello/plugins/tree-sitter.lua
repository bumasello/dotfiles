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

		vim.api.nvim_create_autocmd("FileType", {
			pattern = ensure_installed,
			callback = function()
				vim.treesitter.start()
				vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
