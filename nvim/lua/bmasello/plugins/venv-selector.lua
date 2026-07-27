return {
	"linux-cultist/venv-selector.nvim",
	dependencies = { "nvim-telescope/telescope.nvim" },
	ft = "python",
	keys = {
		{ "<leader>vs", "<cmd>VenvSelect<cr>", desc = "Selecionar venv Python" },
	},
	opts = {
		options = {
			notify_user_on_venv_activation = true,
		},
	},
}
