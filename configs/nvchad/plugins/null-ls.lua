local present, null_ls = pcall(require, "null-ls")

if not present then
	return
end

local b = null_ls.builtins

local sources = {
	b.formatting.prettier,
	b.formatting.black,
	b.formatting.stylua,
	b.formatting.shfmt.with({ extra_args = { "-i", "4", "-c" } }),
	b.formatting.terraform_fmt,
}

null_ls.setup({
	debug = true,
	sources = sources,
	on_attach = function()
		vim.api.nvim_create_autocmd("BufWritePost", {
			callback = function()
				vim.lsp.buf.format()
			end,
		})
	end,
})
