" Manage plugins with pathogen.vim
execute pathogen#infect()

set encoding=utf8
set t_Co=256
"colorscheme desert256
colorscheme zenburn

" Show filename in terminal title
set title

" No wait time when inserting text in multiple lines.
" Side effect: disables cursor keys in Insert mode.
set noesckeys

" Enable backspace in Insert mode (sometimes disabled by default)
set backspace=indent,eol,start

" Disable modelines
set nomodeline
set modelines=0

" Indenting options
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set smarttab
set autoindent
set cindent

if exists('+colorcolumn')
    set colorcolumn=80
endif

" GVim options
set guioptions-=T " Remove toolbar
set guioptions-=r " Remove right scroll-bar

filetype plugin on
filetype indent on
syntax on
set hlsearch

"Start syntax parsing from the start of the file
"(useful to fix broken syntax highlighting)
noremap <F9> <Esc>:syntax sync fromstart<CR>
inoremap <F9> <C-o>:syntax sync fromstart<CR>
"Revert back to the default `sync` value
"(`fromstart` is likely to be slow)
noremap <F10> <Esc>:syntax sync minlines=200<CR>
inoremap <F10> <C-o>:syntax sync minlines=200<CR>

" Disable automatic folding of markdown files
let g:vim_markdown_folding_disabled=1

" Disable-enable folding
set nofoldenable " Disabled by default
noremap <F7> <Esc>:set foldenable \| FastFoldUpdate<CR>
inoremap <F7> <C-o>:set foldenable \| FastFoldUpdate<CR>
noremap <F8> <Esc>:set nofoldenable<CR>
inoremap <F8> <C-o>:set nofoldenable<CR>

" Toggle trailing whitespace highlighting
noremap <F6> <Esc>:ToggleWhitespace<CR>
inoremap <F6> <C-o>:ToggleWhitespace<CR>

" Automatic foldmethod
au BufWinEnter *.py set foldmethod=indent
au BufWinEnter *.c set foldmethod=syntax
au BufWinEnter *.h set foldmethod=syntax
au BufWinEnter *.cpp set foldmethod=syntax
au BufWinEnter *.hpp set foldmethod=syntax

" Disable matching of parenthesis
let g:loaded_matchparen = 1

let g:airline_theme="hybridline"
" Show the status line as the second line from bottom
set laststatus=2

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 0
let g:airline#extensions#tabline#tab_nr_type = 2
let g:airline#extensions#whitespace#enabled = 0
