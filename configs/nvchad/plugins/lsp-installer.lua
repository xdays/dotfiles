local lspInstaller = require("nvim-lsp-installer")
M = {}

M.setup = function()
    lspInstaller.setup({
      ensure_installed = {
          "bashls",
          "gopls",
          "terraformls",
          "pyright",
          "dockerls",
          "elixirls",
          "sumneko_lua",
      }
    })
end

return M
