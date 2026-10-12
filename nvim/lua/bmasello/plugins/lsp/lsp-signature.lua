-- Ao digitar "(" ou "," numa chamada de método, abre uma janelinha acima do
-- cursor com a assinatura (parâmetros e tipos) e destaca o parâmetro atual.
-- Carrega junto com o lspconfig, antes de qualquer servidor conectar.
return {
	"ray-x/lsp_signature.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		hint_enable = false, -- só a janela; sem o texto virtual com emoji do padrão
		handler_opts = { border = "rounded" },
	},
}
