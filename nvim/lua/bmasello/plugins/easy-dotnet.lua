-- Ponte entre o nvim-dap e o netcoredbg: é o que faz o Console.ReadLine()
-- aceitar digitação durante o debug (o netcoredbg puro não abre terminal
-- integrado). Precisa do servidor `dotnet tool install -g EasyDotnet`.
-- O LSP fica desligado aqui porque quem cuida dele é o roslyn.nvim.
-- o servidor mora em ~/.dotnet/tools; garante o PATH mesmo quando o nvim foi
-- aberto de um shell que não tem essa pasta (shell antigo, outro terminal)
local dotnet_tools = vim.fn.expand("~/.dotnet/tools")
if not vim.env.PATH:find(dotnet_tools, 1, true) then
	vim.env.PATH = dotnet_tools .. ":" .. vim.env.PATH
end

return {
	"GustavEikaas/easy-dotnet.nvim",
	ft = { "cs", "csproj", "sln", "slnx" },
	cmd = "Dotnet",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
	opts = {
		lsp = { enabled = false },
		debugger = {
			bin_path = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg",
			console = "integratedTerminal",
		},
	},
}
