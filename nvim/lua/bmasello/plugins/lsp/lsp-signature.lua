-- Ao digitar "(" ou "," numa chamada de método, abre uma janelinha com a
-- assinatura (parâmetros e tipos) e destaca o parâmetro atual.
-- Carrega junto com o lspconfig, antes de qualquer servidor conectar.

-- A janela da assinatura e o menu do nvim-cmp escolhem o lado (acima ou abaixo
-- do cursor) cada um por conta própria; quando escolhem o mesmo, o menu cobre a
-- assinatura. Aqui a assinatura vai sempre pro lado oposto ao do menu.

-- altura máxima do menu do cmp: window.completion.max_height em nvim-cmp.lua
local MENU = 9

-- janela do menu do cmp, se estiver aberta
local function janela_do_menu()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local flutuante = vim.api.nvim_win_get_config(win).relative ~= ""
		if flutuante and vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "cmp_menu" then
			return win
		end
	end
end

-- o menu do cmp está (ou, se fechado, vai abrir) acima do cursor?
local function menu_acima()
	local linha = vim.fn.screenpos(0, vim.fn.line("."), vim.fn.col(".")).row
	local menu = janela_do_menu()
	if menu then
		return vim.api.nvim_win_get_position(menu)[1] + 1 < linha
	end
	-- fechado: a mesma conta do cmp, que só sobe quando o menu não cabe embaixo
	return vim.o.lines - linha <= MENU
end

-- Recebe as opções que o plugin calculou pra janela e devolve o ajuste vertical
-- (somado ao do plugin). Também encolhe a janela quando o espaço é curto.
local function lado_oposto_ao_menu(janela)
	local acima = vim.fn.winline() - 1
	local abaixo = vim.fn.winheight(0) - vim.fn.winline()
	local altura = janela.height or 1
	local norte = (janela.anchor or "NW"):sub(1, 1) == "N"
	-- onde o plugin já ia pôr: âncora S é sempre acima; âncora N só sobe se couber com folga
	local ja_acima = not norte or acima >= altura + 3

	if not menu_acima() then
		if ja_acima then
			return 0
		end
		local h = math.min(altura, acima - 2)
		if h < 1 then
			-- 3 primeiras linhas da janela: não cabe acima, vai pra baixo do menu
			-- (nas 2 primeiras o plugin já desce 2 linhas por conta própria)
			return MENU - (janela.anchor and 0 or 2)
		end
		janela.height, janela.max_height = h, h
		return -(h + 3)
	end

	local h = math.min(altura, abaixo - 2)
	if h < 1 then
		-- fim da janela: não cabe abaixo, fica acima do menu
		return ja_acima and -MENU or 0
	end
	if not ja_acima then
		return 0
	end
	janela.height, janela.max_height = h, h
	return (norte and altura or h) + 3
end

-- O plugin só posiciona a janela quando ela abre; depois não mexe mais enquanto a
-- assinatura for a mesma. Só que perto do fim da tela o menu muda de lado conforme
-- a quantidade de sugestões (com poucas cabe embaixo, com muitas sobe) e pode abrir
-- em cima dela. Roda toda vez que o menu abre: se cobriu, move a assinatura pro
-- outro lado do cursor; se lá não couber, pra depois do menu.
local function tira_de_baixo_do_menu()
	local assinatura = _LSP_SIG_CFG and _LSP_SIG_CFG.winnr
	local menu = janela_do_menu()
	if not (menu and assinatura and vim.api.nvim_win_is_valid(assinatura)) then
		return
	end
	-- linhas da tela (a partir de 1) que cada janela ocupa; a da assinatura tem borda
	local pos = vim.api.nvim_win_get_position(assinatura)
	local altura = vim.api.nvim_win_get_height(assinatura)
	local a1, a2 = pos[1] + 1, pos[1] + altura + 2
	local m1 = vim.api.nvim_win_get_position(menu)[1] + 1
	local m2 = m1 + vim.api.nvim_win_get_height(menu) - 1
	if a2 < m1 or m2 < a1 then
		return
	end

	local cursor = vim.fn.screenpos(0, vim.fn.line("."), vim.fn.col(".")).row
	local topo_janela = vim.fn.win_screenpos(0)[1]
	local fim_janela = topo_janela + vim.fn.winheight(0) - 1
	local topo, h
	if m2 < cursor then
		-- menu acima: assinatura abaixo do cursor; sem espaço, acima do menu
		h = math.min(altura, fim_janela - cursor - 2)
		topo = cursor + 1
		if h < 1 then
			h = math.min(altura, m1 - topo_janela - 2)
			topo = m1 - h - 2
		end
	else
		-- menu abaixo: assinatura acima do cursor; sem espaço, abaixo do menu
		h = math.min(altura, cursor - topo_janela - 2)
		topo = cursor - h - 2
		if h < 1 then
			h = math.min(altura, fim_janela - m2 - 2)
			topo = m2 + 1
		end
	end
	if h < 1 then
		return
	end
	vim.api.nvim_win_set_config(assinatura, {
		relative = "editor",
		anchor = "NW",
		row = topo - 1,
		col = pos[2],
		height = h,
	})
end

return {
	"ray-x/lsp_signature.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		hint_enable = false, -- só a janela; sem o texto virtual com emoji do padrão
		handler_opts = { border = "rounded" },
		floating_window_off_y = lado_oposto_ao_menu,
	},
	config = function(_, opts)
		require("lsp_signature").setup(opts)
		-- o cmp só carrega no primeiro InsertEnter; o gancho entra junto com ele
		vim.api.nvim_create_autocmd("InsertEnter", {
			once = true,
			callback = function()
				local ok, cmp = pcall(require, "cmp")
				if ok then
					cmp.event:on("menu_opened", function()
						vim.schedule(tira_de_baixo_do_menu)
					end)
				end
			end,
		})
	end,
}
