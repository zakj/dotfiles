" Cabin colorscheme
"
" Maintainer:	Zak Johnson <zak@hellocabin.com>
" Last Change:	2012-01-08
" URL: https://github.com/cabin/cabin-colorscheme

" ----------------------------------------------------------------------------
" help highlight-groups
" help group-name
" au BufWritePost <buffer> source %
" ----------------------------------------------------------------------------

set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "cabin"


" General VIM chrome.

hi Normal guifg=#888888 guibg=#191919
hi Cursor guibg=#cccc99
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
hi MatchParen guifg=yellow guibg=#000000  " XXX

hi Pmenu guifg=fg guibg=#000000
hi PmenuSel gui=bold guifg=bg guibg=fg
hi WildMenu gui=bold guifg=bg guibg=fg

hi Search guibg=yellow  " XXX
hi IncSearch guifg=yellow  " XXX
hi Visual guifg=bg guibg=fg

"hi SpecialKey  "XXX listchars, <C-F> from :map, etc.
hi NonText guifg=#224466
hi SpecialKey guifg=#333399

" Conceal		placeholder characters substituted for concealed " 		text (see 'conceallevel')
" Directory	directory names (and other special names in listings)
" DiffAdd		diff mode: Added line |diff.txt|
" DiffChange	diff mode: Changed line |diff.txt|
" DiffDelete	diff mode: Deleted line |diff.txt|
" DiffText	diff mode: Changed text within a changed line |diff.txt|
" ErrorMsg	error messages on the command line
" Folded		line used for closed folds
" FoldColumn	'foldcolumn'
" ModeMsg		'showmode' message (e.g., "-- INSERT --")
" MoreMsg		|more-prompt|
" Question	|hit-enter| prompt and yes/no questions
" Title		titles for output from ":set all", ":autocmd" etc.
" WarningMsg	warning messages



" Syntax highlighting.

hi Comment gui=italic guifg=#4f4f4f guibg=bg
hi Constant gui=NONE guifg=#8b002e guibg=bg
hi Identifier gui=NONE guifg=#7065a7 guibg=bg
hi Statement gui=bold guifg=#7a7aa3 guibg=bg
hi Type gui=NONE guifg=#6f6f94 guibg=bg
hi Operator gui=NONE guifg=#636363 guibg=bg

"hi PreProc guifg=#3333cc
hi PreProc guifg=#666699

"hi Special guifg=#54548d
hi Special guifg=#454574
"hi Special guifg=#636363
"hi Special guifg=#700025
"hi Special guifg=#990033
"hi Special guifg=#3d3d67

hi Underlined NONE
hi Ignore NONE
hi Error gui=NONE guifg=#b5b4b4 guibg=#990033
hi Todo gui=NONE guifg=#000000 guibg=#7a7aa3


" hi Constant guifg=#3b8686
" hi Identifier guifg=#6c8c6c
" hi Statement guifg=#cf817e
" hi Statement guifg=#a26563
" hi Statement guifg=#b87270
" "hi PreProc guifg=#9f836f
" hi Type guifg=#9f836f
" hi Type guifg=#744847
" hi Type guifg=#8b5655
" "hi Type guifg=#7065a7
" hi Special guifg=#7065a7
" "hi Comment gui=italic guifg=#7f8379
" "hi Normal guifg=#c7ccbd
" hi Error guifg=#000000 guibg=#fe4365
" hi Todo guifg=#000000 guibg=#f0ea7b
" " TODO
" "hi Error guif=#000000 guibg=#fe4365


"hi Constant guifg=#cc8888
"hi Constant guifg=#aa8888
"hi Constant guifg=#336666
"hi Identifier guifg=#669966
"hi Statement guifg=#996699
"hi PreProc NONE
"hi Type gui=bold guifg=#8888bb
"hi Special NONE
"hi Underlined NONE
"hi Ignore NONE
"hi Error NONE
"hi Todo gui=bold guifg=#505458 guibg=#222222
"hi Todo guibg=#cccc66 guifg=bg

"hi Comment gui=italic guifg=#3a4685
"hi Identifier guifg=#545c8b
"hi Type guifg=#7b6cae
"hi Constant guifg=#6d77ad
"


" 	*Comment	any comment
" 
" 	*Constant	any constant
" 	 String		a string constant: "this is a string"
" 	 Character	a character constant: 'c', '\n'
" 	 Number		a number constant: 234, 0xff
" 	 Boolean	a boolean constant: TRUE, false
" 	 Float		a floating point constant: 2.3e10
" 
" 	*Identifier	any variable name
" 	 Function	function name (also: methods for classes)
" 
" 	*Statement	any statement
" 	 Conditional	if, then, else, endif, switch, etc.
" 	 Repeat		for, do, while, etc.
" 	 Label		case, default, etc.
" 	 Operator	"sizeof", "+", "*", etc.
" 	 Keyword	any other keyword
" 	 Exception	try, catch, throw
" 
" 	*PreProc	generic Preprocessor
" 	 Include	preprocessor #include
" 	 Define		preprocessor #define
" 	 Macro		same as Define
" 	 PreCondit	preprocessor #if, #else, #endif, etc.
" 
" 	*Type		int, long, char, etc.
" 	 StorageClass	static, register, volatile, etc.
" 	 Structure	struct, union, enum, etc.
" 	 Typedef	A typedef
" 
" 	*Special	any special symbol
" 	 SpecialChar	special character in a constant
" 	 Tag		you can use CTRL-] on this
" 	 Delimiter	character that needs attention
" 	 SpecialComment	special things inside a comment
" 	 Debug		debugging statements
" 
" 	*Underlined	text that stands out, HTML links
" 
" 	*Ignore		left blank, hidden  |hl-Ignore|
" 
" 	*Error		any erroneous construct
" 
" 	*Todo		anything that needs extra attention; mostly the
" 			keywords TODO FIXME and XXX





"    var. 1 = #56619b = rgb(86,97,155)
"    var. 2 = #545c8b = rgb(84,92,139)
"    var. 3 = #3a4685 = rgb(58,70,133)
"    var. 4 = #6772ad = rgb(103,114,173)
"    var. 5 = #6d77ad = rgb(109,119,173)
" 
"    var. 1 = #66569c = rgb(102,86,156)
"    var. 2 = #60548c = rgb(96,84,140)
"    var. 3 = #4b3a85 = rgb(75,58,133)
"    var. 4 = #7767ae = rgb(119,103,174)
"    var. 5 = #7b6cae = rgb(123,108,174)
" 
"    var. 1 = #4d7293 = rgb(77,114,147)
"    var. 2 = #4c6984 = rgb(76,105,132)
"    var. 3 = #355b7d = rgb(53,91,125)
"    var. 4 = #5f84a6 = rgb(95,132,166)
"    var. 5 = #6487a6 = rgb(100,135,166)
" 
"    var. 1 = #e3c170 = rgb(227,193,112)
"    var. 2 = #cbb16f = rgb(203,177,111)
"    var. 3 = #c2a04c = rgb(194,160,76)
"    var. 4 = #e8c97d = rgb(232,201,125)
"    var. 5 = #e8cb85 = rgb(232,203,133)








" kuler: urban wardrobe
" #4a4a3e dark brown
" #a3a38f light brown
" #424f57 slate grey
" #1c1c1c dark grey
" #b5b4b4 white


"hi StatusLine guibg=#b5b4b4 guifg=#424f57
"hi StatusLine guibg=#1c1c1c guifg=#424f57
"hi StatusLineNC guibg=#1c1c1c guifg=#1c1c1c
"hi StatusLine guifg=#3a4685 guibg=#b5b4b4 
"hi StatusLineNC guifg=#3a4685 guibg=bg
"hi VertSplit guifg=bg guibg=#3a4685
"hi StatusLine guifg=#545c8b guibg=#b5b4b4 
"hi StatusLineNC guifg=#545c8b guibg=bg
"hi VertSplit guifg=bg guibg=#545c8b
" TODO: something fancy (not really a TODO!)

" Mrxvt.color0:  rgb:0/0/0
" Mrxvt.color1:  rgb:b/7/5
" Mrxvt.color2:  rgb:5/b/7
" Mrxvt.color3:  rgb:a/a/7
" Mrxvt.color4:  rgb:5/7/b
" Mrxvt.color5:  rgb:a/7/a
" Mrxvt.color6:  rgb:7/a/a
" Mrxvt.color7:  rgb:c/c/c
" Mrxvt.color8:  rgb:50/54/58
" Mrxvt.color9:  rgb:d/9/7
" Mrxvt.color10: rgb:7/d/9
" Mrxvt.color11: rgb:c/c/9
" Mrxvt.color12: rgb:7/9/d
" Mrxvt.color13: rgb:c/9/c
" Mrxvt.color14: rgb:9/c/c
" Mrxvt.color15: rgb:e0/e4/e8



" From http://vimcasts.org/episodes/creating-colorschemes-for-vim/
" * can you see the cursor?
" * enable line & columns highlighting (:set cul cuc). Can you see a crosshair
" for the cursor position?
" * enable line numbering (:set number). Can you see the line numbers?
" * split a window with :split and :vsplit. Are the status lines and vertical
" separators clearly visible? Can you tell which is the current window?
" * enable hlsearch (:set hls) and search for a pattern. Can you see the
" matches?
" * go into visual mode (shift-V). Can you easily see which line is selected?
" Can you differentiate between visual mode and highlighted search matches?
" * fold some text (:set foldmethod=manual then make a visual selection and
" press zf). Can you identify the folded text?
" * bring up the autocomplete popup menu (type the first few characters of a
" word, then press ctrl-n). Is it clear which item in the list is selected?
" * position your cursor on some brackets. Does the matching bracket stand out
" in a way that is identifiable? Could the matching bracket be confused with
" the cursor?
