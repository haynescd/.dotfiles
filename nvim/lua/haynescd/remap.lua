vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("n", "<A-j>", "<CMD>cnext<CR>")
vim.keymap.set("n", "<A-k>", "<CMD>cprev<CR>")

-- Toggle Inlay Hints
vim.keymap.set("n", "<leader>tt", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end
)
