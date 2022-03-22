local M = {}

M.setup_lsp = function(attach, capabilities)
    local lspconfig = require "lspconfig"

    -- lspservers with default config
    local servers = {"bashls", "gopls", "terraform_lsp", "pyright", "dockerls"}

    for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup {
              on_attach = attach,
            capabilities = capabilities,
            flags = {debounce_text_changes = 150}
        }
    end

    -- lspconfig.efm.setup {
    --     init_options = {documentFormatting = true},
    --     settings = {
    --       rootMarkers = {".git/"},
    --       languages = {
    --         lua = {
    --           {formatCommand = "lua-format -i", formatStdin = true}
    --         },
    --           python = {
    --           {formatCommand = "black --quiet -", formatStdin = true}
    --         }
    --       }
    --     }
    -- }

    -- elixirls setting
    lspconfig["elixirls"].setup {
        cmd = {os.getenv("HOME") .. "/.lsp/elixir-ls/rel/language_server.sh"}
    }
end

return M
