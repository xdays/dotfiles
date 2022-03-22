local null_ls = require "null-ls"
local b = null_ls.builtins

local sources = {
    b.formatting.prettierd.with {filetypes = {"html", "markdown", "css"}},
    b.formatting.black, -- python
    b.formatting.terraform_fmt, -- python
    b.formatting.lua_format, -- lua
    b.diagnostics.luacheck.with {extra_args = {"--global vim"}}, -- lua
    b.formatting.shfmt, -- shell
    b.diagnostics.shellcheck.with {diagnostics_format = "#{m} [#{c}]"}
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
