--[[
" Terminal Mode Maps "
nmap <leader>vt :vsp<cr>:term<cr>
nmap <leader>ht :split<cr>:term<cr>
tnoremap <Esc> <C-\><C-n>
--]]

vim.keymap.set("n", "<leader>vt", ":vsp<cr>:term<cr>")
vim.keymap.set("n", "<leader>ht", ":split<cr>:term<cr>")
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")

vim.api.nvim_create_autocmd("TermOpen", {
  callback = function(ev)
    vim.o.number = false
    vim.o.relativenumber = false
    vim.cmd('startinsert')
  end}
)
