set autoindent
set backspace=2
set backupdir=~/.vim/backup,.
set cedit=  " Prevent default <C-f> from opening the command-line window.
set cinoptions=:0
set confirm
set diffopt+=iwhite
set directory=~/.vim/backup//,.
set expandtab
set hidden
set nohlsearch
set incsearch
set nojoinspaces  " Only once space after a sentence.
set laststatus=2  " Always show the status bar.
set linebreak
set listchars=tab:[-,trail:_,extends:>,precedes:<
set pastetoggle=<F1>
set report=0
set ruler
set showbreak=+
set showcmd
set shiftwidth=4
set shortmess=fnrxotTI
set smarttab
set textwidth=79
set title
set ttimeoutlen=50  " avoid waiting after O
set viminfo=""
set whichwrap=""
set wildmode=list:longest
set wildignore=*.o,*.pyc

let mapleader = ","
let maplocalleader = ","
let g:fuzzy_ignore = "*.pyc"

" Bundles:
" https://github.com/wincent/Command-T.git
" https://github.com/mileszs/ack.vim.git
" https://github.com/tpope/vim-surround.git
" https://github.com/tpope/vim-repeat.git
" https://github.com/vim-scripts/Bexec.git
" https://github.com/tpope/vim-fugitive.git
"
" https://github.com/kchmck/vim-coffee-script.git
" https://github.com/tpope/vim-endwise.git
" https://github.com/tpope/vim-rails.git

" Pathogen must be initialized before filetype plugin stuff below.
silent! call pathogen#runtime_append_all_bundles()
silent! call pathogen#helptags()
nnoremap <C-u> :GundoToggle<CR>

if has("syntax")
    filetype plugin indent on
    syntax on
    let g:pyindent_open_paren = '&sw'
    let g:pyindent_continue = '&sw'
    let g:is_bash = 1
endif

if has("autocmd")
    au FileType hog setl textwidth=0
    au FileType make setl noexpandtab shiftwidth=8
    au FileType mail setl textwidth=72
    au FileType taskpaper setl noexpandtab shiftwidth=2 tabstop=2
    au FileType coffee,cucumber,ruby,slim setl shiftwidth=2
    au FileType css,html,htmljinja setl shiftwidth=2
    au BufNewFile,BufRead *.ccss setfiletype clevercss
    au BufNewFile,BufRead *.json setfiletype javascript
    au BufNewFile,BufRead /tmp/mutt-* setfiletype mail
    au BufNewFile,BufRead /tmp/mutt-* set notitle
    au BufNewFile,BufRead ~/repos/good.is/* setl noexpandtab tabstop=4
endif

if has("multi_byte")
    function! SetBomb()
        if &termencoding == ""
            let &termencoding = &encoding
        endif
        setl encoding=utf-8
        setl fileencodings=ucs-bom,utf-8,latin1
        setl fileencoding=utf-8 bomb
    endfunction
    " Handle fancy characters in shared notes.
    au BufNewFile,BufRead ~/Dropbox/Zek/Notes/* call SetBomb()
endif

cmap <C-a> <Home>
cmap <C-e> <End>

" I never want to run man from inside vim.
map <silent> K k
" Y should act like D or C.
nmap Y y$
" And I don't want LeftMouse to reposition the cursor.
map <LeftMouse> <Nop>
imap <LeftMouse> <Nop>

map <silent> <C-H> :set hlsearch!<CR>
map <silent> <C-J> :bnext<CR>
map <silent> <C-K> :bprevious<CR>
map <silent> <C-N> :cnext<CR>
map <silent> <C-P> :cprevious<CR>
" Toggle between the previously-used buffer.
map <silent> gb <C-^>
" Count instances of the word under the cursor.
map <silent> <Leader>c mc"cyiw:%s/\<<C-R>c\>//gn<CR>`c
" Prompt to open a file in the same directory as the current buffer's file.
map <silent> <Leader>E :e <C-R>=expand("%:p:h") . "/"<CR>
map <silent> <Leader>l :set list!<CR>
map <silent> <Leader>p :set paste!<CR>
" Easily edit the contents of the q register (what I use for macros).
map <silent> <Leader>qp mqGo<ESC>"qp
map <silent> <Leader>qd "qdd`q
map <silent> <Leader>s :set spell!<CR>
" Remove trailing whitespace.
map <silent> <leader>S mS:%s/\s\s*$//<CR>`S
" Underline current line.
map <silent> <Leader>u yypVr-
map <silent> <Leader>U yypVr=
" Vertical split/unsplit.
map <silent> <Leader>v :set columns=161<CR>:vsplit<CR>
map <silent> <Leader>V :close<CR>:set columns=80<CR>
map <silent> <Leader>w :set wrap!<CR>
" Save and close the current buffer, switching to the previous buffer to avoid
" closing the window.
map <silent> <leader>x :update<CR>:bprevious<CR>:bwipeout #<CR>
" Unix timestamp.
iabbr <Leader><Leader>s <C-R>=strftime('%s')<CR>

if exists(":function")
    function! ToggleWrap()
        set linebreak!
        set wrap!
        if exists('g:old_showbreak') && &showbreak == ''
            let &showbreak = g:old_showbreak
        else
            let g:old_showbreak = &showbreak
            let &showbreak = ''
        endif
    endfunction
    map <silent> <Leader>w :call ToggleWrap()<CR>

    " Hitting tab at the beginning of a line indents; elsewhere completes.
    function! InsertTabWrapper()
        let col = col('.') - 1
        if !col || getline('.')[col - 1] !~ '\k'
            return "\<tab>"
        else
            return "\<c-n>"
        endif
    endfunction
    inoremap <Tab> <C-R>=InsertTabWrapper()<CR>

    " GUI setup, to avoid a separate .gvimrc.
    if has('gui_running')
        colorscheme macvim
        set bg=dark
        highlight Comment guifg=#666699
        highlight MatchParen guibg=bg guifg=LightGoldenrod
        highlight VertSplit guifg=DarkSlateGray guibg=bg
        set guicursor+=a:blinkon0
        set guifont=Menlo:h12
        set guioptions=aegimt
        set lines=40
        set columns=80
        function! ToggleZoom()
            if &columns > 80
                set lines=40 columns=80
            else
                set lines=999 columns=124
            endif
        endfunction
        map <silent> <Leader>z :call ToggleZoom()<CR>
    endif
endif

" Hooray backslashes.
set grepprg=find\ .\ \\!\ -path\ '*.svn/*'\ \\!\ -type\ d\ -print0\ \\\|\ xargs\ -0\ egrep\ -nHI
if has("user_commands")
    command! -nargs=+ -complete=tag G :grep <args>
endif

augroup Binary
  au!
  au BufReadPre  *.sol,*.sav let &bin=1
  au BufReadPost *.sol,*.sav if &bin | %!xxd
  au BufReadPost *.sol,*.sav set ft=xxd | endif
  au BufWritePre *.sol,*.sav if &bin | %!xxd -r
  au BufWritePre *.sol,*.sav endif
  au BufWritePost *.sol,*.sav if &bin | %!xxd
  au BufWritePost *.sol,*.sav set nomod | endif
augroup END

map <silent> <Leader>e :CommandT<CR>
map <silent> <Leader>f :CommandTBuffer<CR>
map <silent> <Leader>F :CommandTFlush<CR>
nnoremap <CR> :CommandTBuffer<CR>
nnoremap <Space> :buffer #<CR>

let g:CommandTMatchWindowAtTop = 1
let coffee_no_trailing_space_error = 1

noremap ; :

if filereadable(expand('~/.local/vimrc'))
    source ~/.local/vimrc
endif
