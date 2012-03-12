" {{{ Options
set autoindent
"set autowrite                     " TODO: maybe?
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
set ruler                          " TODO: remove if I customize statusline
set shiftround                     " Indent in multiples of 'shiftwidth'.
set shiftwidth=4
set shortmess+=I
set showbreak=+
set smarttab
set nostartofline                  " Maintain cursor column on C-f, C-b.
set textwidth=79
set title
set ttimeoutlen=50                 " Avoid waiting after `O`.
set viminfo=""                     " Always start with a clean slate.
set whichwrap=""
set wildignore+=compiled,vendor,*.o,*.pyc
set wildmode=list:longest
" }}}

" {{{ Mappings
let mapleader = ","
let maplocalleader = mapleader

noremap ; :

" Swap to the previous buffer on spacebar.
nnoremap <Space> :buffer #<CR>

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
map <Leader>E :e <C-R>=expand("%:p:h") . "/"<CR>

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
filetype off
set runtimepath+=~/.vim/bundle/vundle
call vundle#rc()

Bundle 'gmarik/vundle'
Bundle 'cabin/cabin-colorscheme'
Bundle 'wincent/Command-T'
Bundle 'mileszs/ack.vim'
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-endwise'
Bundle 'tpope/vim-rails'
Bundle 'tpope/vim-repeat'
Bundle 'tpope/vim-surround'
Bundle 'indentpython.vim'
Bundle 'kchmck/vim-coffee-script'
Bundle 'pangloss/vim-javascript'
Bundle 'uggedal/jinja-vim'
Bundle 'bbommarito/vim-slim'
Bundle 'groenewege/vim-less'

" Plugin configuration
colorscheme cabin
let g:CommandTMatchWindowAtTop = 1
let coffee_no_trailing_space_error = 1

" Plugin mappings
map <silent> <Leader>e :CommandT<CR>
map <silent> <Leader>f :CommandTBuffer<CR>
map <silent> <Leader>F :CommandTFlush<CR>

filetype plugin indent on
syntax enable
" }}}

" {{{ GUI configuration
if has('gui_running')
    set guicursor+=a:blinkon0
    set guifont=Menlo:h12
    set guioptions=aegimt  " TODO: check this
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

" Custom settings by filetype or filename.
if has('autocmd')
    augroup vimrc
        au!
        au FileType make setl noexpandtab shiftwidth=8
        au FileType mail setl textwidth=72
        au FileType coffee,cucumber,ruby,slim setl shiftwidth=2
        au FileType css,html,htmljinja setl shiftwidth=2
        au BufNewFile,BufRead *.json setfiletype javascript
        au BufNewFile,BufRead /tmp/mutt-* setfiletype mail
    augroup end
endif

" Handle term escape code to set paste mode automatically.
if &term =~ "xterm.*"
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
