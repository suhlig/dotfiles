execute pathogen#infect()
set nocompatible
set number
syntax on
filetype plugin indent on

" https://github.com/fatih/vim-go-tutorial
set autowrite
map <C-n> :cnext<CR>
map <C-m> :cprevious<CR>
let mapleader = ","
autocmd FileType go nmap <leader>b  <Plug>(go-build)
autocmd FileType go nmap <leader>r  <Plug>(go-run)

" Default to two spaces
set expandtab tabstop=2 shiftwidth=2 softtabstop=2 autoindent

" Backspace moves to previous line
set backspace=indent,eol,start

" delete trailing blanks for the given filetypes
autocmd FileType javascript,python,ruby,java,go autocmd BufWritePre * :%s/\s\+$//e

" https://github.com/junegunn/fzf#as-vim-plugin
set rtp+=/usr/local/opt/fzf

" https://github.com/scrooloose/nerdtree
autocmd vimenter * NERDTree
