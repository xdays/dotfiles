return {
    {
        "jose-elias-alvarez/null-ls.nvim",
        after = "nvim-lspconfig",
        config = function() require("custom.plugins.null-ls").setup() end
    }, {
        "'williamboman/nvim-lsp-installer",
        config = function()
            require("custom.plugins.lsp-installer").setup()
        end
    }, {"rcarriga/nvim-notify"}
}
