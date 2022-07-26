local M = {}

local pluginConfs = require("custom.plugins.configs")

M.plugins = {
    options = {
      lspconfig = {
        setup_lspconf = "custom.plugins.lspconfig",
      },
    },
    override = { ["nvim-treesitter/nvim-treesitter"] = pluginConfs.treesitter },
    user = require("custom.plugins"),
}

M.ui = {
    theme = "monekai",
}

return M
