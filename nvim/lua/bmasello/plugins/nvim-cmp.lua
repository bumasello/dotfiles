return {
	"hrsh7th/nvim-cmp",
	event = "InsertEnter",
	dependencies = {
		"hrsh7th/cmp-buffer", -- source for text in buffer
		"hrsh7th/cmp-path", -- source for file system paths
		"L3MON4D3/LuaSnip", -- snippet engine
		"saadparwaiz1/cmp_luasnip", -- for autocompletion
		"rafamadriz/friendly-snippets", -- useful snippets
		"onsails/lspkind.nvim", -- vs-code like pictograms
	},
	config = function()
		local cmp = require("cmp")

		local luasnip = require("luasnip")

		local lspkind = require("lspkind")

		-- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
		require("luasnip.loaders.from_vscode").lazy_load()

		cmp.setup({
			performance = {
				debounce = 0,
				throttle = 0,
				fetching_timeout = 500,
			},
			completion = {
				completeopt = "menu,menuone,preview,noselect",
			},
			window = {
				-- No máximo 9 linhas: assim o menu cabe abaixo do cursor mesmo com ele
				-- encostado no scrolloff (8) e não pula pra cima, onde fica a janela da
				-- assinatura (lsp/lsp-signature.lua usa esse mesmo 9)
				completion = { max_height = 9 },
			},
			snippet = { -- configure how nvim-cmp interacts with snippet engine
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
				["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
				["<C-e>"] = cmp.mapping.abort(), -- close completion window
				["<CR>"] = cmp.mapping.confirm({ select = false }),
				-- Menu aberto: Tab aceita a sugestão (como sempre foi). Menu fechado e
				-- cursor dentro de um snippet: Tab pula pro próximo campo. Precisa valer
				-- no modo "s" também, porque o campo do snippet fica selecionado nele.
				["<Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.confirm({ select = true })
					elseif luasnip.locally_jumpable(1) then
						luasnip.jump(1)
					else
						fallback()
					end
				end, { "i", "s" }),
				-- Shift+Tab volta pro campo anterior do snippet
				["<S-Tab>"] = cmp.mapping(function(fallback)
					if luasnip.locally_jumpable(-1) then
						luasnip.jump(-1)
					else
						fallback()
					end
				end, { "i", "s" }),
			}),
			-- sources for autocompletion
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "luasnip" },
			}, {
				{ name = "buffer" },
				{ name = "path" },
			}),
			-- configure lspkind for vs-code like pictograms in completion menu
			formatting = {
				format = lspkind.cmp_format({
					maxwidth = 50,
					ellipsis_char = "...",
				}),
			},
		})

		-- Um item de LSP pode trazer um comando que é do cliente, não do servidor
		-- (ex.: o `override` do Roslyn, que escreve o método inteiro). O cmp-nvim-lsp
		-- só sabe mandar comando pro servidor, então o que tem tratador local roda aqui.
		-- O autopairs põe o "(" por feedkeys depois do confirm, então o comando também
		-- entra pela fila de teclas (via <Plug>) pra rodar depois dele, e não no meio.
		local pending = nil
		vim.keymap.set("i", "<Plug>(cmp-local-command)", function()
			local run = pending
			pending = nil
			if run then
				run()
			end
		end)

		cmp.event:on("confirm_done", function(evt)
			local command = evt.entry:get_completion_item().command
			local client = evt.entry.source.source.client
			if not command or not client then
				return
			end

			local is_local = (client.commands and client.commands[command.command])
				or vim.lsp.commands[command.command]
			if not is_local then
				return
			end

			local bufnr = vim.api.nvim_get_current_buf()
			pending = function()
				-- O Roslyn calcula o trecho a substituir com o que estava digitado na hora
				-- (ex.: "override ToS"), mas o cmp já apagou o "ToS" ao confirmar. Sem
				-- encurtar o fim até o tamanho real da linha, o nvim_buf_set_text recusa.
				local edit = command.command == "roslyn.client.completionComplexEdit"
					and command.arguments
					and command.arguments[2]
				if edit and edit.range then
					local last = edit.range["end"]
					local line = vim.api.nvim_buf_get_lines(bufnr, last.line, last.line + 1, false)[1] or ""
					last.character = math.min(last.character, #line)
				end

				client:exec_cmd(command, { bufnr = bufnr })
			end
			vim.schedule(function()
				local keys = vim.api.nvim_replace_termcodes("<Plug>(cmp-local-command)", true, false, true)
				vim.api.nvim_feedkeys(keys, "m", false)
			end)
		end)
	end,
}
