local M = {}

M.treesitter = {
	ensure_installed = {
		"lua",
		"vim",
		"html",
		"css",
		"javascript",
		"json",
		"toml",
		"markdown",
		"c",
		"bash",
		"hcl",
		"python",
		"elixir",
		"go",
	},
}

M.mason = {
	ensure_installed = {
		-- lua stuff
		"lua-language-server",
		"stylua",

    -- shell
    "shfmt",

		-- web dev stuff
		"css-lsp",
		"html-lsp",
		"pyright",
		"gopls",
		"typescript-language-server",
		"bash-language-server",
		"dockerfile-language-server",
		"terraform-ls",
		"elixir-ls",
	},
}

return M
