-- LSP de Java: o Eclipse JDT Language Server, o mesmo da extensão Java do VS Code.
-- Quem sobe o servidor é o after/ftplugin/java.lua, a cada buffer .java; aqui
-- só declara o plugin. O binário e os bundles de debug/teste vêm do mason.
return {
	"mfussenegger/nvim-jdtls",
	ft = "java",
}
