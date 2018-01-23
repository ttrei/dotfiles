" Manage plugins with pathogen.vim
execute pathogen#infect()
Helptags


" GVim settings
set guifont=Consolas\ 13


set encoding=utf8
set t_Co=256
set background=dark
"colorscheme desert256
"colorscheme zenburn
colorscheme Tomorrow-Night-Eighties

" Enable mouse in terminal (only in visual mode)
set mouse=v
" Ctrl+C copies visually selected text to X clipboard. Vim must be compiled
" with +xterm_clipboard option (see :version).
:vmap <C-C> "+y

" Show filename in terminal title
set title

" Enable backspace in Insert mode (sometimes disabled by default)
set backspace=indent,eol,start

" Better tab-autocomplete
set wildmode=longest,list,full
set wildmenu

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

" Treat all numbers as decimal
set nrformats=

if exists('+colorcolumn')
    set colorcolumn=100
endif

" GVim options
set guioptions-=T " Remove toolbar
set guioptions-=m " Remove menubar
set guioptions-=r " Remove right scroll-bar

filetype plugin on
filetype indent on
syntax on
set incsearch
set hlsearch
set nowrapscan

"Start syntax parsing from the start of the file
"(useful to fix broken syntax highlighting)
nnoremap <F9> <Esc>:syntax sync fromstart<CR>
"Revert back to the default `sync` value
"(`fromstart` is likely to be slow)
nnoremap <F10> <Esc>:syntax sync minlines=200<CR>

" Disable-enable folding
set nofoldenable " Disabled by default
nnoremap <F7> <Esc>:set foldenable \| FastFoldUpdate<CR>
nnoremap <F8> <Esc>:set nofoldenable<CR>

" Toggle trailing whitespace highlighting
nnoremap <F6> <Esc>:ToggleWhitespace<CR>

" Wrap/unwrap elements such as function arguments, arrays etc.
nnoremap <silent> \w :ArgWrap<CR>

" Disable automatic wrappping while typing
set formatoptions-=tc

" Numbertoggle
:nnoremap <silent> <C-n> :set relativenumber!<cr>

" xml file fold settings
au FileType xml setlocal shiftwidth=2 foldmethod=indent tabstop=2

" Automatic foldmethod
au BufWinEnter *.py set foldmethod=indent
au BufWinEnter *.c set foldmethod=syntax
au BufWinEnter *.h set foldmethod=syntax
au BufWinEnter *.cpp set foldmethod=syntax
au BufWinEnter *.hpp set foldmethod=syntax

" clang-format
map <C-K> :pyf /home/reinis/.vim/clang-format.py<cr>

" Disable matching of parenthesis
let g:loaded_matchparen = 1

let g:airline_theme="hybridline"
" Show the status line as the second line from bottom
set laststatus=2

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 0
let g:airline#extensions#tabline#tab_nr_type = 0
let g:airline#extensions#tabline#fnamemod = ':t:r'
let g:airline#extensions#whitespace#enabled = 0
let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''

"CtrlP
set wildignore+=*\\tmp\\*,*.swp,*.zip,*.exe,*.class,*.jar,*.html
let g:ctrlp_working_path_mode = 'r'
let g:ctrlp_by_filename = 1
" Search code tags (classes, functions etc.)
nnoremap \t :CtrlPBufTag<CR>
" Open and jump to the tagbar
nnoremap \a :TagbarOpen fj<CR>
" Freeze/unfreeze tagbar
nnoremap \f :TagbarTogglePause<CR>
" Close tagbar automatically (press 'c' while in tagbar to toggle)
let g:tagbar_autoclose = 1

"BufExplorer
let g:bufExplorerFindActive=0   " Don't jump around when opening a buffer


if executable('ag')
  " Use Ag over Grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
endif

" Move through tabs
nnoremap <F4> gt
nnoremap <F3> gT

" Exit visual mode and search in the previously selected range
vnoremap \/ <Esc>/\%V

" Search for selection ('*' - forward; '#' - backward)
vnoremap <silent>* <ESC>:call VisualSearch('/')<CR>/<CR>
vnoremap <silent># <ESC>:call VisualSearch('?')<CR>?<CR>

    function! VisualSearch(direction)
        let l:register=@@
        normal! gvy
        let l:search=escape(@@, '$.*/\[]')
        if a:direction=='/'
            execute 'normal! /'.l:search
        else
            execute 'normal! ?'.l:search
        endif
        let @/=l:search
        normal! gV
        let @@=l:register
    endfunction
