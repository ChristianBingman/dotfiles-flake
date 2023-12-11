--[[
set splitright
set hidden set nocompatible
set showmatch
set ignorecase
set hlsearch
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set autoindent
set relativenumber
set wildmode=longest,list
set hid
syntax on
set ttyfast
--]]
vim.opt.splitright = true
vim.opt.hidden = true
vim.opt.showmatch = true
vim.opt.ignorecase = true
vim.opt.hlsearch = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.relativenumber = true
vim.opt.hid = true
vim.opt.ttyfast = true
vim.opt.wildmode = "longest,list"
vim.opt.mouse = ""

vim.cmd([[ syntax enable ]])
