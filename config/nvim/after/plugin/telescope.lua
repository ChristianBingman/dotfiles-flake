-- nnoremap <leader>tff <cmd>Telescope find_files<cr>
-- nnoremap <leader>tlg <cmd>Telescope live_grep<cr>
-- nnoremap <leader>tb <cmd>Telescope buffers<cr>
local builtin = require('telescope.builtin')
vim.keymap.set("n", "<leader>tff", builtin.find_files, {})
vim.keymap.set("n", "<leader>tlg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>tb", builtin.buffers, {})
