set nocompatible

" don't use 'conceal in rust
let g:no_rust_conceal=1

silent! call pathogen#infect()

if has("gui_running")
  if has("win32")
    set guifont=consolas:h12
  elseif has("mac")
    set guifont=Monaco:h14
  else
    set guifont=Ubuntu\ Mono\ 12
  endif

  set guioptions-=r
  set guioptions-=T
  set guioptions-=m
  set guioptions-=e
endif

" -- general settings, set terminal background to RGB (0, 43, 54)
set background=dark
colorscheme solarized 
syntax enable " enable syntax processing
set showcmd " show command in bottom bar
set number " show line numbers
filetype plugin indent on " load file-specific indent files
set lazyredraw
set showmatch

set backspace=indent,eol,start

set expandtab "tab are spaces
set tabstop=2 "number of visual spaces
set softtabstop=2 " number of spaces in tab
set shiftwidth=2

set autoindent

" bash like tab completion
set wildmenu
set wildmode=longest,list

set directory=~/.vim/_swaps
set backupdir=~/.vim/_backups

set splitright
set splitbelow

" break long line
set linebreak

" trailing space
highlight TrailingSpace ctermbg=white guibg=#073642
match TrailingSpace /\s\+$/

" switch to buffers in a new tab instead splitting
set switchbuf=usetab

" -- autocommands
if has("autocmd")
  augroup all
    autocmd!
    au BufRead,BufNewFile *.\(md\|markdown\) set filetype=markdown
    au BufRead,BufNewFile *.\(pkg\|vw\|ddo\|sbs\|zm\|src\) set filetype=vdf
    au BufRead,BufNewFile *.\json set ft=javascript

    au FileType make set noexpandtab
    au FileType gitcommit set tw=72 colorcolumn=73
    au FileType markdown set tw=0

    au FileType go set noexpandtab
    au FileType go set shiftwidth=4
    au FileType go set softtabstop=4
    au FileType go set tabstop=4
  augroup END
endif

" -- status line stuff --
if has("statusline")
  " alwasy show status bar
  set laststatus=2

  " Start the status line (filename, modified, readonly)
  set statusline=%f\ %m%r

  " Add filetype + eoltype
  set statusline+=[%{&ff}/%Y]

  " Finish the statusline
  set statusline+=\ %=Line:%l[%p%%]
  set statusline+=\ Col:%v
endif

"searching
set incsearch
set hlsearch

set scrolloff=5
set sidescrolloff=5

if exists('&colorcolumn')
  set colorcolumn=80
endif

if (has("nvim"))
  "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif

" For neovim > 0.1.5
if (has("termguicolors"))
  set termguicolors
endif

" netrw settings
let g:netrw_list_hide = '.*\.pyc'

" Folding
set foldenable
set foldlevelstart=10
set foldnestmax=10

set foldmethod=indent

" --- custom key mappings ---
" tab navigation like firefox
nnoremap <C-S-tab> :tabprevious<CR>
nnoremap <C-tab> :tabnext<CR>
nnoremap <C-t> :tabnew<CR>

" yanking/pasting to or from other applications
nnoremap <leader>y "+y
vnoremap <leader>y "+y
nnoremap <leader>p "+gP
vnoremap <leader>p "+gP

" open help in a vertical window
nnoremap <leader>h :vertical help
vnoremap <leader>h :vertical help

" shortcut for clearing the search pattern
nnoremap <leader><space> :ClearSearchPattern<cr>
vnoremap <leader><space> :ClearSearchPattern<cr>

" tabularize shortcut
vnoremap <leader>t :Tabularize /
nnoremap <leader>t :Tabularize /

" command-t shortcut
vnoremap <leader>r :CommandT<CR>
nnoremap <leader>r :CommandT<CR>

" next/previous error
vnoremap <leader>n :lnext<CR>
nnoremap <leader>n :lnext<CR>
vnoremap <leader>N :lprevious<CR>
nnoremap <leader>N :lprevious<CR>

" entering new line without entering insert mode
nnoremap oo o<Esc>k
nnoremap OO O<Esc>j

" --- custom functions ---
" Increase a number in a column -- use C-v and then C-a
function! Incr()
  let a = line('.') - line("'<")
  let c = virtcol("'<")
  if a > 0
    execute 'normal! '.c.'|'.a."\<C-a>"
  endif
  normal `<
endfunction
vnoremap <C-a> :call Incr()<CR>

" --- custom commands ---
command! ClearSearchPattern let @/ = ""
command! KillWhitespace :normal :%s/\s\+$//g<cr> :ClearSearchPattern
