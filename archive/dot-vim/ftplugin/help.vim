setl statusline=\ [HELP]\ %F%=\ %P
" q leaves help; enter and backspace navigate tags.
nnoremap <buffer> q :q!<CR>
nnoremap <buffer> <CR> g<C-]>
nnoremap <buffer> <BS> <C-T>
