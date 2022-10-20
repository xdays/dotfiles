local null_ls = require("null-ls")
local b = null_ls.builtins

local sources = {
    b.formatting.prettier,
    b.formatting.black,
    b.formatting.stylua.with({ extra_args = { "--indent-type", "Spaces", "--indent-width", "4" } }),
    b.formatting.shfmt.with({ extra_args = { "-i", "4", "-c" } }),
    b.formatting.terraform_fmt,
}

local M = {}

M.setup = function()
    null_ls.setup({
        debug = true,
        sources = sources,

        -- format on save
        on_attach = function(client)
            if client.server_capabilities.document_formatting then
                vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
            end
        end,
    })
end

return M
