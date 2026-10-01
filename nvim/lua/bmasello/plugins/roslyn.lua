-- LSP de C#: o mesmo servidor Roslyn do C# Dev Kit do VS Code.
-- O binário vem do mason (roslyn-language-server); o plugin acha a .sln/.csproj
-- e conecta. Keymaps vêm do LspAttach em lsp/lsp-config.lua.
return {
	"seblyng/roslyn.nvim",
	ft = { "cs", "razor" },
	opts = {},
	config = function(_, opts)
		vim.lsp.config("roslyn", {
			settings = {
				["csharp|inlay_hints"] = {
					csharp_enable_inlay_hints_for_implicit_object_creation = true,
					csharp_enable_inlay_hints_for_implicit_variable_types = true,
					csharp_enable_inlay_hints_for_lambda_parameter_types = true,
					csharp_enable_inlay_hints_for_types = true,
					dotnet_enable_inlay_hints_for_parameters = true,
				},
				["csharp|code_lens"] = {
					dotnet_enable_references_code_lens = true,
				},
				["csharp|completion"] = {
					dotnet_show_completion_items_from_unimported_namespaces = true,
					dotnet_show_name_completion_suggestions = true,
				},
			},
		})
		require("roslyn").setup(opts)
	end,
}
