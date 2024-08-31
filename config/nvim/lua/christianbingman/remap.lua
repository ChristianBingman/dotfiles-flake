vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("i", "ii", "<ESC>")

vim.keymap.set("n", "<leader>ma", "<cmd>mark a<CR>")
vim.keymap.set("n", "<leader>mb", "<cmd>mark b<CR>")
vim.keymap.set("n", "<leader>mc", "<cmd>mark c<CR>")
vim.keymap.set("n", "<leader>md", "<cmd>mark d<CR>")
vim.keymap.set("n", "<leader>me", "<cmd>mark e<CR>")
vim.keymap.set("n", "<leader>mf", "<cmd>mark f<CR>")

--[[
" Buffer Maps "
--]]

vim.keymap.set("n", "<leader>h", "<c-w>h")
vim.keymap.set("n", "<leader>l", "<c-w>l")
vim.keymap.set("n", "<leader>j", "<c-w>j")
vim.keymap.set("n", "<leader>k", "<c-w>k")
vim.keymap.set("n", "<leader>vs", ":vsp<cr>")
vim.keymap.set("n", "<leader>hs", ":split<cr>")
vim.keymap.set("n", "<leader>bo", "<c-w>_ <c-w><bar>")
vim.keymap.set("n", "<leader>be", "<c-w>=")
vim.keymap.set("n", "<S-h>", ":bprev<cr>")
vim.keymap.set("n", "<S-l>", ":bnext<cr>")
