" https://github.com/tpope/vim-markdown/blob/master/ftdetect/markdown.vim
autocmd BufNewFile,BufRead *.markdown,*.md,*.mdown,*.mkd,*.mkdn
      \ if &ft =~# '^\%(conf\|modula2\)$' |
      \   set ft=markdown |
      \ else |
      \   setf markdown |
      \ endif
