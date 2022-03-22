local M = {}

M.treesitter = {
    ensure_installed = {
        "lua", "vim", "html", "css", "javascript", "json", "toml", "markdown",
        "c", "bash", "hcl", "python", "elixir", "go"
    }
}

M.nvimtree = {git = {enable = true}}

return M
