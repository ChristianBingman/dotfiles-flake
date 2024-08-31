--" Markdown Preview Settings "
--let g:mkdp_browser = '/bin/true'
--let g:mkdp_port = '3001'

vim.g.mkdp_browser = '/bin/true'
vim.g.mkdp_port = '3000'

vim.keymap.set("n", "<leader>md", ":MarkdownPreviewToggle<cr>")
