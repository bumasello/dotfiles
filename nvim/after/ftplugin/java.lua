-- Java usa 4 espaços (convenção do Eclipse e do Google Java Style sem tab)
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4

local jdtls = require("jdtls")
local mason = vim.fn.stdpath("data") .. "/mason/packages"

-- Raiz do projeto: wrapper do Maven/Gradle marca o topo de um multi-módulo;
-- sem ele, o pom/build mais próximo ou o .project do Eclipse (projeto de curso);
-- arquivo solto vira projeto na própria pasta.
local root = vim.fs.root(0, { "mvnw", "gradlew" })
	or vim.fs.root(0, { "pom.xml", "build.gradle", "build.gradle.kts", ".project" })
	or vim.fs.root(0, { ".git" })
	or vim.fn.expand("%:p:h")

-- o jdtls guarda o índice de cada projeto numa pasta própria, fora do projeto
local workspace = vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fn.fnamemodify(root, ":p:h:gs?/?%?")

-- jars que dão ao jdtls o debug (java-debug-adapter) e a execução de testes (java-test)
local bundles = vim.fn.glob(mason .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar", true, true)
for _, jar in ipairs(vim.fn.glob(mason .. "/java-test/extension/server/*.jar", true, true)) do
	local nome = vim.fn.fnamemodify(jar, ":t")
	-- estes dois rodam fora do servidor e quebram o jdtls se forem carregados nele
	if nome ~= "com.microsoft.java.test.runner-jar-with-dependencies.jar" and nome ~= "jacocoagent.jar" then
		table.insert(bundles, jar)
	end
end

jdtls.start_or_attach({
	name = "jdtls",
	cmd = {
		vim.fn.stdpath("data") .. "/mason/bin/jdtls",
		"--jvm-arg=-javaagent:" .. mason .. "/jdtls/lombok.jar",
		"-data",
		workspace,
	},
	root_dir = root,
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
	init_options = { bundles = bundles },
	settings = {
		java = {
			signatureHelp = { enabled = true },
			inlayHints = { parameterNames = { enabled = "all" } },
			referencesCodeLens = { enabled = true },
			completion = {
				-- import estático sugerido no autocomplete, como no Eclipse
				favoriteStaticMembers = {
					"org.junit.jupiter.api.Assertions.*",
					"org.mockito.Mockito.*",
					"java.util.Objects.requireNonNull",
				},
			},
			sources = { organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 } },
		},
	},
	on_attach = function()
		-- liga o debug; as classes com main viram configs com console integrado, que é
		-- o que deixa o Scanner(System.in) receber digitação durante o debug
		jdtls.setup_dap({ hotcodereplace = "auto" })

		local opts = { buffer = 0, silent = true }
		opts.desc = "Java: organizar imports"
		vim.keymap.set("n", "<leader>jo", jdtls.organize_imports, opts)
		opts.desc = "Java: extrair variável"
		vim.keymap.set({ "n", "v" }, "<leader>jv", jdtls.extract_variable, opts)
		opts.desc = "Java: extrair método"
		vim.keymap.set("v", "<leader>jm", function() jdtls.extract_method(true) end, opts)
		opts.desc = "Java: testar a classe"
		vim.keymap.set("n", "<leader>jt", jdtls.test_class, opts)
		opts.desc = "Java: testar o método sob o cursor"
		vim.keymap.set("n", "<leader>jT", jdtls.test_nearest_method, opts)
	end,
})
