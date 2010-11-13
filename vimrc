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
set linebreak
set listchars=tab:[-,trail:_,extends:>,precedes:<
set pastetoggle=<F1>
set report=0
set noruler
set showbreak=+
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
let g:fuzzy_ignore = "*.pyc"

" Pathogen must be initialized before filetype plugin stuff below.
call pathogen#runtime_append_all_bundles()
nnoremap <C-u> :GundoToggle<CR>

if has("syntax")
    filetype plugin indent on
    syntax on
    "highlight Comment cterm=bold
    "highlight MatchParen ctermbg=blue guibg=lightblue
    "highlight Search ctermfg=black ctermbg=green guibg=green
    "highlight PmenuSel ctermfg=black ctermbg=white

    let g:pyindent_open_paren = '&sw'
    let g:pyindent_continue = '&sw'
    let g:is_bash = 1
endif

if has("autocmd")
    au FileType hog setl textwidth=0
    au FileType make setl noexpandtab shiftwidth=8
    au FileType mail setl textwidth=72
    au FileType nerdtree nmap <buffer> <Enter> o
    au BufNewFile,BufRead *.ccss setfiletype clevercss
    au BufNewFile,BufRead /tmp/mutt-* setfiletype mail
    au BufNewFile,BufRead /tmp/mutt-* set notitle
    au BufNewFile,BufRead ~/repos/good.is/* setl noexpandtab
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
" Save and close the current buffer.
map <silent> <leader>x :update<CR>:bwipeout<CR>
" Unix timestamp.
iabbr <Leader><Leader>s <C-R>=strftime('%s')<CR>

if exists(":function")
    function! ToggleWrap()
        set linebreak!
        set wrap!
        if &showbreak == ''
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
    function! ConfigureGUI()
        colorscheme macvim
        set bg=dark
        highlight Comment guifg=#666699
        highlight MatchParen guibg=bg guifg=LightGoldenrod
        set guicursor+=a:blinkon0
        set guifont=Consolas:h12
        set guioptions=aegimt
        set lines=40
        set columns=80
    endfunction
    if has('gui_running')
        call ConfigureGUI()
    endif
    " MacVIM tries to be smarter than me and remember some settings from other
    " windows.
    autocmd GUIEnter * call ConfigureGUI()
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
map <silent> <Leader>r :LustyFilesystemExplorerFromHere<CR>
map <silent> <Leader>f :LustyBufferExplorer<CR>

let g:LustyJugglerSuppressRubyWarning = 1
let g:CommandTSplitAtTop = 1
let g:CommandTMatchWindowAtTop = 1
