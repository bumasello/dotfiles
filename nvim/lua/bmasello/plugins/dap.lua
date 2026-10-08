-- Debug de C# com netcoredbg (mason). Atalhos iguais aos do Visual Studio,
-- pra bater com o que aparece nas aulas: F5 roda/continua, F9 ou <leader>b
-- marca breakpoint, F10 pula a linha, F11 entra no método, Shift+F11 sai dele.
-- O F11 só chega aqui porque foi desligado no Windows Terminal (era tela cheia).
-- Quem compila, sobe o netcoredbg e liga o terminal é o easy-dotnet.nvim.

-- F5 sem sessão aberta compila e debuga o projeto; com sessão, continua
local function rodar_ou_continuar()
	local dap = require("dap")
	if dap.session() then
		dap.continue()
	else
		vim.cmd("Dotnet debug")
	end
end

return {
	"mfussenegger/nvim-dap",
	dependencies = {
		{ "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
		"theHamsta/nvim-dap-virtual-text", -- mostra o valor das variáveis no fim da linha
	},
	keys = {
		{ "<F5>", rodar_ou_continuar, desc = "Debug: rodar / continuar" },
		{ "<S-F5>", function() require("dap").terminate() end, desc = "Debug: parar" },
		{ "<F17>", function() require("dap").terminate() end, desc = "Debug: parar (Shift+F5 em alguns terminais)" },
		{ "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Debug: breakpoint" },
		{ "<leader>b", function() require("dap").toggle_breakpoint() end, desc = "Debug: breakpoint" },
		{ "<F10>", function() require("dap").step_over() end, desc = "Debug: próxima linha" },
		{ "<F11>", function() require("dap").step_into() end, desc = "Debug: entrar no método" },
		{ "<S-F11>", function() require("dap").step_out() end, desc = "Debug: sair do método" },
		{ "<F23>", function() require("dap").step_out() end, desc = "Debug: sair do método (Shift+F11 em alguns terminais)" },
		-- <leader>u e não <leader>du: com "du" o <leader>d (aviso da linha) esperava 1s pelo "u"
		{ "<leader>u", function() require("dapui").toggle() end, desc = "Debug: abrir/fechar painéis" },
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		dapui.setup()
		require("nvim-dap-virtual-text").setup({})

		-- abre os painéis ao começar; não fecha ao terminar, pra saída do programa continuar visível
		dap.listeners.after.event_initialized["dapui"] = function()
			dapui.open()
		end

		vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
		vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn", linehl = "Visual" })
	end,
}
