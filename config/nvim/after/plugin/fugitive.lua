-- " Fugitive Maps "
-- nnoremap <leader>gs :Git<cr>
-- nnoremap <leader>gb :Git branch -m
-- nnoremap <leader>gc :Git commit<cr>
-- nnoremap <leader>gmm :Git merge remotes/origin/master<cr>
-- nnoremap <leader>gca :Git commit --amend
-- nnoremap <leader>gp :Git push -u origin HEAD<cr>
vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
vim.keymap.set("n", "<leader>gb", ":Git branch -m")
vim.keymap.set("n", "<leader>gc", ":Git commit<cr>")
vim.keymap.set("n", "<leader>gmm", ":Git merge remotes/origin/master<cr>")
vim.keymap.set("n", "<leader>gca", ":Git commit --amend")
vim.keymap.set("n", "<leader>gp", ":Git push origin HEAD")
