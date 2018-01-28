" Options  {{{1
set autoindent
set autoread
set backspace=indent,eol,start
set backupdir=~/.vim/backup,.
set cedit=                         " Don't use the command-line window.
set cinoptions=:0                  " `case` should line up with `switch`.
set colorcolumn=90
set confirm                        " Prompt instead of failing to quit.
set diffopt+=iwhite,vertical
set directory=~/.vim/backup//,.    " Keep swap files in one place.
set encoding=utf-8
set expandtab
set guicursor+=a:blinkon0          " Never blink the cursor.
set fillchars+=vert:│              " Use a proper box bar for vsplits.
set formatoptions+=j               " Remove comment leader when joining lines.
set nofoldenable                   " No folds by default; use `zi` to enable.
set foldmethod=marker
set hidden                         " Don't unload hidden buffers.
set nohlsearch
set incsearch
set nojoinspaces                   " Only once space after a sentence.
set laststatus=2                   " Always show the status line.
set linebreak                      " Don't break lines mid-word.
set listchars=tab:├─,trail:·,extends:…,precedes:…
set mouse=a
set number
set pastetoggle=<F1>               " TODO: consider removing? changing?
set report=0                       " Always report how many lines were changed.
set noruler                        " More verbose ^G output.
set shiftround                     " Indent in multiples of 'shiftwidth'.
set shiftwidth=4
set shortmess+=I
set smarttab
set nostartofline                  " Maintain cursor column on C-f, C-b.
set textwidth=79
set title
set ttimeoutlen=50                 " Avoid waiting after `O`.
set viminfo=""                     " Always start with a clean slate.
set whichwrap=""
set wildignore+=*.o,*.pyc
set wildmenu
set wildmode=longest:full

filetype plugin indent on
syntax enable

" Mappings  {{{1
let mapleader = ","

noremap ; :

" Optionally save and safely close the current buffer.
nmap <silent> <leader>x :update<CR>:Bdelete<CR>

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
map <silent> <C-x> :set number!<CR>:GitGutterSignsToggle<CR>

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

" I never use the command-line window.
nmap q: :q

" Sort the selection (primarily useful with CSS).
vmap <silent> <Leader>s :!sort -d<CR>

" Show syntax highlighting and linked syntax for cursor position.
nmap <Leader>P :echo <SID>SynLinks()<CR>
function! <SID>SynLinks()
    let l:synid = synID(line('.'), col('.'), 1)
    return join(uniq(map([l:synid, synIDtrans(l:synid)], 'synIDattr(v:val, "name")')), '->')
endfunction

" Pressing tab at the beginning of a line indents; elsewhere completes.
function! <SID>InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-n>"
    endif
endfunction
inoremap <expr> <Tab> <SID>InsertTabWrapper()

" Plugins  {{{1
silent! if plug#begin('~/.vim/plugged')
    " Appearance
    Plug 'zakj/vim-mourning'
    Plug 'zakj/vim-statusline'

    " Functionality
    Plug 'airblade/vim-gitgutter'
    Plug 'junegunn/vim-easy-align'
    Plug 'justinmk/vim-dirvish'
    Plug 'mbbill/undotree', {'on': 'UndotreeToggle'}
    Plug 'michaeljsmith/vim-indent-object'
    Plug 'moll/vim-bbye'
    Plug 'tomtom/tcomment_vim'
    Plug 'tpope/vim-endwise'
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-ragtag'
    Plug 'tpope/vim-repeat'
    Plug 'tpope/vim-sleuth'
    Plug 'tpope/vim-surround'
    Plug 'vim-scripts/gitignore'
    Plug 'wincent/Command-T', {'do': 'rake make'}
    Plug 'wincent/ferret'

    if has('nvim') || has('job')
        Plug 'w0rp/ale'
    else
        Plug 'scrooloose/syntastic'
    endif

    " Syntax
    Plug 'vim-scripts/indentpython.vim', {'for': 'python'}
    Plug 'pangloss/vim-javascript'
    Plug 'elzr/vim-json'
    Plug 'groenewege/vim-less'
    Plug 'digitaltoad/vim-jade'
    Plug 'wavded/vim-stylus'
    Plug 'posva/vim-vue'

    call plug#end()
endif

" Plugin configuration
silent! colorscheme mourning
let g:CommandTFileScanner = "git"
let g:CommandTGitIncludeUntracked = 1
let g:CommandTMaxHeight = 10
let g:CommandTToggleFocusMap = []
let g:syntastic_mode_map = {'passive_filetypes': ['html']}
let g:syntastic_javascript_checkers = ['eslint']
let g:ale_linters = {'html': [], 'javascript': ['eslint']}

" Plugin mappings
nmap <silent> <Leader>e <Plug>(CommandT)
nmap <silent> <Leader>f <Plug>(CommandTMRU)
nnoremap U :UndotreeToggle<CR>
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

silent! call commandt#Load()
function! <SID>MRUBuffer()
    ruby <<
    stack = CommandT::MRU.stack
    VIM::command('b %d' % stack[-2].number) if stack.length > 1
.
endfunction
nnoremap <silent> <Space> :call <SID>MRUBuffer()<CR>

" GUI configuration  {{{1
if has('gui_running')
    set guifont=Menlo:h14
    set guioptions=aegimt

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

" Misc  {{{1

" Handle term escape code to set paste mode automatically.
if !has('nvim') && &term =~ '\v^(screen|xterm)'
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
