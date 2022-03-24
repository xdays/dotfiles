local null_ls = require "null-ls"
local b = null_ls.builtins

local sources = {
    b.formatting.prettierd.with {
        filetypes = {"html", "javascript", "css", "markdown"}
    }, b.formatting.black, b.formatting.lua_format,
    b.formatting.shfmt.with {extra_args = {"-i", "4", "-c"}}
}

local M = {}

M.setup = function()
    null_ls.setup {
        debug = true,
        sources = sources,

        -- format on save
        on_attach = function(client)
            if client.resolved_capabilities.document_formatting then
                vim.cmd "autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()"
            end
        end
    }
end

return M
