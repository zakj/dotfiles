" {{{ Options
set autoindent
set autoread
set backspace=indent,eol,start
set backupdir=~/.vim/backup,.
set cedit=                         " Don't use the command-line window.
set cinoptions=:0                  " `case` should line up with `switch`.
set colorcolumn=81
set confirm                        " Prompt instead of failing to quit.
set diffopt+=iwhite
set directory=~/.vim/backup//,.    " Keep swap files in one place.
set encoding=utf-8
set expandtab
set fillchars+=vert:│              " Use a proper box bar for vsplits.
set formatoptions+=j               " Remove comment leader when joining lines.
set nofoldenable                   " No folds by default; use `zi` to enable.
set hidden                         " Don't unload hidden buffers.
set incsearch
set nojoinspaces                   " Only once space after a sentence.
set laststatus=2                   " Always show the status line.
set linebreak                      " Don't break lines mid-word.
set listchars=tab:├─,trail:·,extends:…,precedes:…
set mouse=""
set pastetoggle=<F1>               " TODO: consider removing? changing?
set report=0                       " Always report how many lines were changed.
set ruler
set shiftround                     " Indent in multiples of 'shiftwidth'.
set shiftwidth=4
set shortmess+=I
set showbreak=↪
set smarttab
set nostartofline                  " Maintain cursor column on C-f, C-b.
set textwidth=79
set title
set ttimeoutlen=50                 " Avoid waiting after `O`.
set viminfo=""                     " Always start with a clean slate.
set whichwrap=""
set wildignore+=*.o,*.pyc
set wildmode=list:longest

filetype plugin indent on
syntax enable
" }}}

" {{{ Mappings
let mapleader = ","

noremap ; :

" Save and close the current buffer, first switching to the previous buffer to
" ensure the window remains open.
map <silent> <leader>x :update<CR>:bprevious<CR>:bwipeout #<CR>

" Buffer navigation.
map <silent> <C-J> :bnext<CR>
map <silent> <C-K> :bprevious<CR>

" Quickfix navigation.
map <silent> <C-N> :cnext<CR>
map <silent> <C-P> :cprevious<CR>

" Emacs-style beginning/end navigation in command mode.
cmap <C-a> <Home>
cmap <C-e> <End>

" `Y` should act like `D` or `C`.
nmap Y y$

" Common toggles.
map <silent> <Leader>l :set list!<CR>
map <silent> <Leader>p :set paste!<CR>
map <silent> <Leader>s :set spell!<CR>
map <silent> <Leader>w :set wrap!<CR>
map <silent> <C-h> :set hlsearch!<CR>

" Vertical split/unsplit.
map <silent> <Leader>v :set columns=161<CR>:vsplit<CR>
map <silent> <Leader>V :close<CR>:set columns=80<CR>

" Prompt to open a file in the same directory as the current buffer's file.
cnoremap %% <C-R>=expand("%:p:h") . "/"<CR>
map <Leader>E :edit %%

" Remove trailing whitespace.
map <silent> <leader>S mS:%s/\s\s*$//<CR>`S

" Count instances of the word under the cursor.
map <silent> <Leader>c mc"cyiw:%s/\<<C-R>c\>//gn<CR>`c

" Easily edit the contents of the q register (what I use for macros).
map <silent> <Leader>qp mqGo<ESC>"qp
map <silent> <Leader>qd "qdd`q

" Underline current line.
map <silent> <Leader>u yypVr-
map <silent> <Leader>U yypVr=

" Insert a Unix timestamp.
iabbr <Leader><Leader>s <C-R>=strftime('%s')<CR>

" I never use 'keywordprg'.
map K k

" Sort the selection (primarily useful with CSS).
vmap <silent> <Leader>s :!sort -d<CR>

" Pressing tab at the beginning of a line indents; elsewhere completes.
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-n>"
    endif
endfunction
inoremap <Tab> <C-R>=InsertTabWrapper()<CR>
" }}}

" {{{ Plugins
silent! if plug#begin('~/.vim/plugged')
    Plug 'cabin/cabin-colorscheme'
    Plug 'wincent/Command-T', {'do': '/usr/bin/rake make'}
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-endwise'
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-ragtag'
    Plug 'tpope/vim-repeat'
    Plug 'tpope/vim-sleuth'
    Plug 'tpope/vim-surround'
    Plug 'airblade/vim-gitgutter'
    Plug 'mbbill/undotree'
    Plug 'michaeljsmith/vim-indent-object'
    Plug 'rking/ag.vim', {'on': 'Ag'}
    Plug 'bufmru.vim'
    Plug 'gitignore'

    Plug 'scrooloose/syntastic'
    Plug 'indentpython.vim'
    Plug 'kchmck/vim-coffee-script'
    Plug 'pangloss/vim-javascript'
    Plug 'mitsuhiko/vim-jinja'
    Plug 'elzr/vim-json'
    Plug 'fatih/vim-go'
    Plug 'groenewege/vim-less'
    Plug 'digitaltoad/vim-jade'
    Plug '5long/pytest-vim-compiler'
    Plug 'reinh/vim-makegreen'

    call plug#end()
endif

" Plugin configuration
silent! colorscheme cabin
let g:CommandTFileScanner = "git"
let g:CommandTMaxHeight = 10
let g:CommandTToggleFocusMap = []
let g:go_disable_autoinstall = 1
let g:go_fmt_command = "gofmt"
let g:syntastic_mode_map = {'passive_filetypes': ['html']}
hi link coffeeSpaceError NONE

" Plugin mappings
nnoremap <silent> <Leader>e :CommandT<CR>
nnoremap <silent> <Leader>f :CommandTMRU<CR>
nnoremap <silent> <Leader>t :MakeGreen %<CR>
nnoremap <silent> <Leader>T :MakeGreen<CR>
nnoremap U :UndotreeToggle<CR>
" }}}

" {{{ GUI configuration
if has('gui_running')
    set guicursor+=a:blinkon0
    set guifont=Menlo:h12
    set guioptions=aegimt
    set lines=40 columns=80

    " Swap windows with ⌥`.
    set macmeta
    nmap <M-`> <C-w><C-w>
    imap <M-`> <Esc><C-w><C-w>

    " Shortcuts for some common window sizes.
    function! ToggleZoom(wide)
        if a:wide == 0 && &lines == 40
            set lines=999
        elseif a:wide == 1 && &columns == 80
            set lines=999 columns=124
        else
            set lines=40 columns=80
        endif
    endfunction
    map <Leader>z :call ToggleZoom(0)<CR>
    map <Leader>Z :call ToggleZoom(1)<CR>
endif
" }}}

" Handle term escape code to set paste mode automatically.
if &term =~ '\v^(screen|xterm)'
    let &t_ti = &t_ti . "\e[?2004h"
    let &t_te = "\e[?2004l" . &t_te
    function! XTermPasteBegin(ret)
        set pastetoggle=<Esc>[201~
        set paste
        return a:ret
    endfunction
    map <expr> <Esc>[200~ XTermPasteBegin("i")
    imap <expr> <Esc>[200~ XTermPasteBegin("")
endif

" Local overrides.
if filereadable(expand('~/.local/vimrc'))
    source ~/.local/vimrc
endif

" vim:foldmethod=marker
