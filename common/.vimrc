execute pathogen#infect()
set nocompatible
set number
syntax on
filetype plugin indent on

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

" Toggle NERDTree
nnoremap <C-n> :NERDTreeToggle<CR>

" Automatically close NerdTree when you open a file
let NERDTreeQuitOnOpen = 1
let NERDTreeShowHidden = 1

" https://github.com/scrooloose/nerdtree/issues/928
let g:NERDTreeNodeDelimiter = "\u00a0"

