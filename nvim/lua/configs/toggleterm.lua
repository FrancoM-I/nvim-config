-- Configuración de lazy.nvim para agregar toggleterm.nvim
require("lazy").setup({
	{
		"akinsho/toggleterm.nvim",
		version = "*", -- Puedes especificar una versión o usar la más reciente
		config = function()
			require("toggleterm").setup({
				size = 20,
				open_mapping = [[<C-\>]], -- Mapeo para abrir la terminal (opcional)
				hide_numbers = true,
				shade_terminals = true,
				shading_factor = "2",
				start_in_insert = true,
				persist_size = true,
				close_on_exit = true,
				shell = vim.o.shell,
				float_opts = {
					border = "curved",
					winblend = 3,
				},
			})

			-- Mapeos personalizados para abrir la terminal en distintos modos
			local map = vim.api.nvim_set_keymap
			local opts = { noremap = true, silent = true }

			-- <leader>h para abrir la terminal en modo horizontal
			map("n", "<C-h>", "<cmd>ToggleTerm direction=horizontal<CR>", opts)

			-- <leader>v para abrir la terminal en modo vertical
			map("n", "<C-v>", "<cmd>ToggleTerm direction=vertical<CR>", opts)

			-- <leader>t para abrir la terminal en modo flotante
			map("n", "<C-t>", "<cmd>ToggleTerm direction=float<CR>", opts)
		end,
	},
})
