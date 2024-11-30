return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.6",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = function()
			return require("configs.telescope")
		end,
		--function(_,opts)
		--	    require("telescope").setup(opts)
		--  end
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			local configs = require("nvim-treesitter.configs")
			configs.setup({
				ensure_installed = {
					"vim",
					"lua",
					"vimdoc",
					"html",
					"css",
					"javascript",
					"typescript",
					"tsx",
					"c",
					"rust",
					"svelte",
					"cpp",
					"python",
					"yaml",
					"zig",
				},
				sync_install = false,
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},
	{
		"norcalli/nvim-colorizer.lua",
		config = true,
		opts = function()
			DEFAULT_OPTIONS = {
				RGB = true,
				RRGGBB = true,
				names = true,
				RRGGBBAA = true,
				rgb_fn = true,
				hsl_fn = true,
				css = true,
				css_fn = false,
				mode = "background",
				require("colorizer").setup(),
			}
		end,
	},
	{
		"williamboman/mason.nvim",
		cmd = { "Mason", "MasonInstall", "MasonInstallAll", "MasonUpdate", "MasonUninstallAll" },
		opts = function()
			return require("configs.mason")
		end,
		config = function(_, opts)
			require("mason").setup(opts)
			vim.api.nvim_create_user_command("MasonInstallAll", function()
				if opts.ensure_installed and #opts.ensure_installed > 0 then
					vim.cmd("MasonInstall " .. table.concat(opts.ensure_installed, " "))
				end
			end, {})
			vim.g.mason_binaries_list = opts.ensure_installed
		end,
	},
	{ "williamboman/mason-lspconfig.nvim" },
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "williamboman/mason.nvim" },
			{ "williamboman/mason-lspconfig.nvim" },
		},
		config = function()
			require("configs.lspconfig")
		end,
	},
	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		lazy = false,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		opts = function()
			return require("configs.nvimtree")
		end,
		config = function(_, opts)
			require("nvim-tree").setup(opts)
		end,
	},
	{
		-- Thank you to Josean for his video https://youtu.be/NL8D8EkphUw?si=3ZAt7ZJ0S1HuDJ_M
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
		},
		opts = function()
			return require("configs.nvim-cmp")
		end,
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				completion = {
					completeopt = "menu,menuone,preview,noselect",
				},
				snippet = { -- configure how nvim-mp interacts with snippet engine
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-K>"] = cmp.mapping.select_prev_item(), --previous suggestion
					["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
					["<C-e>"] = cmp.mapping.abort(), -- close completion window
					["<CR>"] = cmp.mapping.confirm({ select = false }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				}),
			})
		end,
	},
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = function()
			return require("configs.formating")
		end,
		config = function(_, opts)
			require("conform").setup(opts)
		end,
	},
	{
		"rust-lang/rust.vim",
		ft = "rust",
		init = function()
			vim.g.rustfmt_autosave = 1
		end,
	},
	{
		"mrcjkb/rustaceanvim",
		version = "^4", -- Recommended
		lazy = false, -- This plugin is already lazy
		ft = "rust",
		dependencies = {
			"neovim/nvim-lspconfig",
		},
		config = function()
			local bufnr = vim.api.nvim_get_current_buf()
			vim.keymap.set("n", "<leader>a", function()
				vim.cmd.RustLsp("codeAction") -- supports rust-analyzer's grouping
				vim.cmd.RustLsp("debug")
				vim.cmd.RustLsp("debuggables")
				-- or, to run the previous debuggable:
				vim.cmd.RustLsp({ "debuggables", bang = true })
				-- or, to override the executable's args:
				vim.cmd.RustLsp({ "debuggables", "arg1", "arg2" })
				-- or vim.lsp.buf.codeAction() if you don't want grouping.
			end, { silent = true, buffer = bufnr })
			vim.api.nvim_create_user_command("RustDebuggables", function()
				vim.cmd("RustLsp debuggables")
			end, {})
		end,
	},
	{
		"mfussenegger/nvim-dap",
		--lldb is required for debuggin to work:
		--vim.keymap.set("n", "<leader>ds", vim.cmd.DapSidebar)
		config = function()
			vim.api.nvim_create_user_command("DapSidebar", function()
				local widgets = require("dap.ui.widgets")
				local sidebar = widgets.sidebar(widgets.scopes)
				sidebar.open()
			end, {})
		end,
	},
	{
		"mfussenegger/nvim-dap-python",
		ft = "python",
		dependencies = {
			"mfussenegger/nvim-dap",
		},
		config = function()
			local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
			require("dap-python").setup(path)
		end,
	},
	{
		"mxsdev/nvim-dap-vscode-js",
		dependencies = {
			"mfussenegger/nvim-dap",
		},
		opts = function()
			return require("configs.dap_js")
		end,
		config = function(_, opts)
			require("dap-vscode-js").setup(opts)
		end,
	},
	--{
	--	"craftzdog/solarized-osaka.nvim",
	--	lazy = false,
	--	priority = 1000,
	--	config = function()
	--		transparent = true
	--		vim.cmd.colorscheme("solarized-osaka")
	--	end,
	--},
	{
		"sainnhe/gruvbox-material",
		lazy = false,
		priority = 1000,
		config = function()
			vim.g.gruvbox_material_foreground = "material"
			vim.g.gruvbox_material_transparent_background = 1
			vim.g.gruvbox_material_background = "hard"
			vim.cmd.colorscheme("gruvbox-material")
		end,
	},
	--	{
	--		"sainnhe/everforest",
	--		lazy = false,
	--		priority = 1000,
	--		config = function()
	--			vim.g.everforest_background = "hard"
	--			vim.g.everforest_ui_contrast = "low"
	--			vim.g.everforest_transparent_background = 2
	--			vim.cmd.colorscheme("everforest")
	--		end,
	--	},
	--{
	--	{
	--	"rmehri01/onenord.nvim",
	--	lazy = false,
	--	priority = 1000,
	--	config = function()
	--		vim.o.background = "dark"
	--		vim.cmd.colorscheme("onenord")
	--	end,
	--},
	--	{
	--	"kvrohit/substrata.nvim",
	--	lazy = false,
	--	priority = 1000,
	--	config = function()
	--		vim.g.substrata_transparent = true
	--		vim.g.substrata_variant = "brighter"
	--		vim.cmd.colorscheme("substrata")
	--	end,
	--	},

	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = function()
			return require("configs.lualine")
		end,
		config = function(_, opts)
			require("lualine").setup(opts)
		end,
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
		-- use opts = {} for passing setup options
		-- this is equivalent to setup({}) function
		opts = function()
			disable_filetype = { "TelescopePrompt", "spectre_panel" }
			disable_in_macro = true -- disable when recording or executing a macro
			disable_in_visualblock = false -- disable when insert after visual block mode
			disable_in_replace_mode = true
			ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=]
			enable_moveright = true
			enable_afterquote = true -- add bracket pairs after quote
			enable_check_bracket_line = true --- check bracket in same line
			enable_bracket_in_quote = true --
			enable_abbr = false -- trigger abbreviation
			break_undo = true -- switch for basic rule break undo sequence
			check_ts = false
			map_cr = true
			map_bs = true -- map the <BS> key
			map_c_h = false -- Map the <C-h> key to delete a pair
			map_c_w = false -- map <c-w> to delete a pair if possible
		end,
	},
}
