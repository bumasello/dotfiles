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
			callback = function(ev)
				vim.treesitter.start()
				-- só troca a indentação se o parser souber indentar; c_sharp não tem
				-- indents.scm e jogava toda linha nova na coluna 0
				local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
				if lang and vim.treesitter.query.get(lang, "indents") then
					vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})
	end,
}
