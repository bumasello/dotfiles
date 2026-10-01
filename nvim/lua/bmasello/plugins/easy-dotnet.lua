-- Ponte entre o nvim-dap e o netcoredbg: é o que faz o Console.ReadLine()
-- aceitar digitação durante o debug (o netcoredbg puro não abre terminal
-- integrado). Precisa do servidor `dotnet tool install -g EasyDotnet`.
-- O LSP fica desligado aqui porque quem cuida dele é o roslyn.nvim.
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
