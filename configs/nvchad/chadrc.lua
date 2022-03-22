local M = {}

local plugin_conf = require "custom.plugins.configs"
local userPlugins = require "custom.plugins"

M.plugins = {
    status = {alpha = true, colorizer = true},
    options = {lspconfig = {setup_lspconf = "custom.plugins.lspconfig"}},
    install = userPlugins,
    default_plugin_config_replace = {
        nvim_treesitter = plugin_conf.treesitter,
        nvim_tree = plugin_conf.nvimtree
    },
    default_plugin_remove = {"akinsho/bufferline.nvim"}
}

M.ui = {
    -- theme = "onedark",
    theme = "monekai"
}

return M
