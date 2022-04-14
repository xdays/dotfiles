local M = {}

local plugin_conf = require "custom.plugins.configs"
local user_plugins = require "custom.plugins"

M.plugins = {
    status = {alpha = true, colorizer = true},
    install = user_plugins,
    default_plugin_config_replace = {nvim_treesitter = plugin_conf.treesitter},
    default_plugin_remove = {"akinsho/bufferline.nvim"}
}

M.ui = {
    -- theme = "onedark",
    theme = "monekai"
}

return M
