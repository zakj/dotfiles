" Cabin colorscheme
"
" Maintainer:	Zak Johnson <zak@hellocabin.com>
" Last Change:	2012-01-15
" URL: https://github.com/cabin/cabin-colorscheme

set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "cabin"


" General VIM chrome.

hi Normal guifg=#888888 guibg=#191919
hi Cursor guibg=#55bb77
hi MatchParen guifg=#55bb77 guibg=#000000
hi StatusLine guifg=#000000 guibg=#b5b4b4
hi StatusLineNC guifg=#000000 guibg=#2a2a2a
hi VertSplit guifg=bg guibg=#000000

" When another window has focus, no status line is current.
augroup cabin_colorscheme
    au!
    au FocusLost * if exists("colors_name") && colors_name == "cabin" | hi StatusLine guibg=#2a2a2a | endif
    au FocusGained * if exists("colors_name") && colors_name == "cabin" | hi StatusLine guibg=#b5b4b4 | endif
augroup end

hi CursorColumn guibg=#111111
hi CursorLine guibg=#111111
hi ColorColumn guibg=#111111
hi LineNr guifg=#2a2a2a guibg=#111111
hi SignColumn guifg=#2a2a2a guibg=#111111
hi FoldColumn guifg=fg guibg=#111111
hi Folded guibg=bg guifg=#e0e4e8

hi Pmenu guifg=bg guibg=fg
hi PmenuSel gui=NONE guifg=fg guibg=#224466
hi WildMenu gui=bold guifg=bg guibg=fg

hi Search guibg=#aaaa77
hi IncSearch guifg=#aaaa77
hi Visual guifg=bg guibg=fg

hi NonText guifg=#224466
hi SpecialKey guifg=#224466

" Unchanged groups (from :help highlight-groups).
" Conceal	placeholder characters substituted for concealed text (see 'conceallevel')
" Directory	directory names (and other special names in listings)
" DiffAdd	diff mode: Added line |diff.txt|
" DiffChange	diff mode: Changed line |diff.txt|
" DiffDelete	diff mode: Deleted line |diff.txt|
" DiffText	diff mode: Changed text within a changed line |diff.txt|
" ErrorMsg	error messages on the command line
" ModeMsg	'showmode' message (e.g., "-- INSERT --")
" MoreMsg	|more-prompt|
" Question	|hit-enter| prompt and yes/no questions
" Title		titles for output from ":set all", ":autocmd" etc.
" WarningMsg	warning messages


" Syntax highlighting (from :help group-name).

hi Comment gui=italic guifg=#4f4f4f guibg=bg
hi Constant gui=NONE guifg=#8b002e guibg=bg
hi Identifier gui=NONE guifg=#7065a7 guibg=bg
hi Statement gui=bold guifg=#7a7aa3 guibg=bg
hi Type gui=NONE guifg=#6f6f94 guibg=bg
hi Operator gui=NONE guifg=#636363 guibg=bg
hi PreProc guifg=#666699
hi Special guifg=#454574

hi Underlined NONE  " TODO
hi Ignore NONE      " TODO
hi Error gui=NONE guifg=#b5b4b4 guibg=#990033
hi Todo gui=NONE guifg=#000000 guibg=#7a7aa3
