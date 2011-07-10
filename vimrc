" Last Modified: dom 10 jul 2011 12:37:37  E. South America Standard Time
"
" == INSTALL ==
"  1 Linux - This .vimrc/.vim requires on linux:
"    VIM 7.3
"    Python 2.7
"    cscope
"    exuberant-ctags
"    pyflakes
"    wmctrl (for the shell plugin)
"
"  2 Windows - on windows use vimfiles instead of .vim. Requirements are:
"    VIM 7.3 (official distribution)
"    Python 2.7
"    mingw32 (with mingw32-make)
"    dejavu-fonts-ttf-2.33.zip (DejaVu Sans Mono fonts)
"    cscope-15.7a-win32rev18-static.zip (cscope)
"    ctags58.zip (ectags)
"    pyflakes-0.3.0.tar.gz (pyflakes)
"
" == TIPS ==
"  1. Multi-buffer replace:
"     :bufdo %s/pattern/substitution/ge | update
"  2. '<C-o>' returns from 'gf'
"  3. Copy/Paste on gvim: "+y / "+gP (ctrl-insert/shift-insert also)
"  4. Mark characters beyond 80 cols: :match Todo '\%80v.*'
"  5. 'zR' expand all folds
"  6. <C-p> <C-n> complete with previous/next token
"     <C-x> <C-o> complete from ctags file
"
" == SOME INSTALLED PLUGINS (updated 2011.06.23) ==
" Align - \ts, \t=        ...Align programming statements
" DoxygenToolkit - :Dox   ...Over function to write api documentation
" delimitMate             ...Auto completes (, ", etc, with corresponding pair
" EnhancedCommentify      ...Needed by Nerd_commenter
" NERD_commenter - \c     ...Toogles comments
" NERD_tree - <C-F5>      ...Shows file tree
" fswitch - \sf           ...Toogles between companion files (.cpp/.cc/.c - .h/.hpp)
" fuf - \ff               ...FuzzyFinder
" matchit                 ...Extends % to match html tags, etc
" minibufexpl             ...Shows window with buffer list
" shell - F6/F11          ...Open files / Fullscreen
" sparkup - <C-e>         ...Zencoding. Tutorial: https://github.com/rstacruz/sparkup
" snipMate                ...Code snippets
" taglist - <C-F8>        ...Displays window with file tags (ectags)
" timestamp               ...Automatically changes timestamps upon save
" visincr - :I            ...With a column marked, create increasing number/date sequence


" General settings
autocmd!
set directory=.,$TEMP
set hlsearch
set ignorecase
set isfname+=32
set mouse=a
set nocompatible
set nowrap
set ruler
set visualbell t_vb="."
syntax on


" Custom make command
if !has("win32")
	let $NPROC=system("grep ^processor /proc/cpuinfo | gawk 'END{printf(\"%s\", $(NF) + 1)}'")
	set makeprg=make\ -j\ $NPROC
endif
if has("win32")
	set viewdir=~/vimfiles/view
	set makeprg=mingw32-make\	-f\	Makefile.w32
endif


if version < 700
	set noloadplugins
else
        filetype off 
	if !has("python")
		let g:pathogen_disabled=['taglist.vim', 'custom']
	endif
        call pathogen#helptags()
        call pathogen#runtime_append_all_bundles()
	filetype on
	filetype plugin on
	filetype indent on
	set autowrite
	set number
        set spelllang=pt
	set sessionoptions+=resize
	set sessionoptions+=unix,slash
	set omnifunc=syntaxcomplete#Complete

	if version >= 703
		if has("win32")
			set undodir=~/vimfiles/undodir
		else
			set undodir=~/.vim/undodir
		endif
		set undofile
		set undolevels=1000
		set undoreload=10000
	endif

	" Color scheme
	if has("win32") && !has("gui_running")
		colorscheme blue
	else
		set t_Co=256
		if has("gui_running")
			colorscheme blackboard
			"colorscheme zenburn
		else
			let g:zenburn_high_Contrast = 1
			colorscheme zenburn
		endif
	endif


	" Timestap fix
	let timestamp_regexp = '\v\C%(<Last %([cC]hanged?|[Mm]odified):\s+)@<=.*$'


	" Invisible chars
	set listchars=tab:»\ ,eol:¬
	highlight NonText guifg=#4a4a59
	highlight SpecialKey guifg=#4a4a59


	" Font and GUI options
	if has("gui_running")
		if has("win32")
			set guifont=DejaVu_Sans_Mono:h10:cANSI
		endif
		set guioptions-=T
		set guioptions-=L
		set guioptions-=r
		set guioptions-=m
		set guioptions-=b
	endif


	" Custom status line
	if has("statusline")
		set statusline=%<%f\ %h%m%r%=%{\"[\".(&fenc==\"\"?&enc:&fenc).((exists(\"+bomb\")\ &&\ &bomb)?\",B\":\"\").\"]\ \"}%k\ %-14.(%l,%c%V%)\ %P
		set laststatus=2
	endif


	" Various autocmd statements
	if has("autocmd")
		autocmd BufRead *.{h,hpp,i} setlocal ft=cpp
		autocmd Filetype c,cpp,java,python,matlab setlocal tabstop=4 shiftwidth=4 expandtab
		autocmd Filetype c,cpp setlocal foldmethod=syntax
		autocmd Filetype xml,html,xhtml,css setlocal shiftwidth=2 expandtab
		autocmd BufEnter *.{c,cpp} let b:fswitchdst = 'h,hpp' | let b:fswitchlocs = 'reg:/^\(.*\)src/\1include/'
		autocmd BufEnter *.{h,hpp} let b:fswitchdst = 'cpp,c' | let b:fswitchlocs = 'reg:/^\(.*\)include/\1src/'
		autocmd WinEnter * setlocal cursorline
		autocmd WinLeave * setlocal nocursorline
		autocmd BufRead,BufNewFile *.g set syntax=antlr3
		autocmd BufWinLeave *.* mkview
		autocmd BufWinEnter *.* silent loadview

		" Automatically inserts guards on new include files
		function! s:insert_gates()
			let gatename = substitute(toupper(expand("%:t")), "\\.", "_", "g") . "_INCLUDED_"
			execute "normal! i#ifndef " . gatename
			execute "normal! o#define " . gatename . " "
			execute "normal! Go#endif /* " . gatename . " */"
			normal! kk
		endfunction
		autocmd BufNewFile *.{h,hpp} call <SID>insert_gates()
	endif


	" MiniBufExplorer plugin
	let g:miniBufExplMapWindowNavVim = 1
	let g:miniBufExplMapWindowNavArrows = 1
	let g:miniBufExplMapCTabSwitchBufs = 1
	let g:miniBufExplModSelTarget = 1
	let g:miniBuffExplUseSingleClick = 1
	let g:miniBuffExplForceSyntaxEnable = 1


        " TagList plugin
	let Tlist_Use_Right_Window = 1


	" Configure ctags/cscope database
	function! s:UpdateTagsCscope()
		silent !ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .
		if filereadable("cscope.out")
			let cscope_exists = 1
		endif
		if has("win32")
			silent !@dir /a-d /b /s *.h *.hpp *.hh *.h++ *.i *.ii *.ipp *.ixx *.i++ *.c *.cpp *.cxx *.c++ *.cc *.py > cscope.files && cscope -b -c -i cscope.files -f cscope.out && del cscope.files
		else
			silent !env LANG=C find . -type f \( -iname '*.h' -o -iname '*.hpp' -o -iname '*.hh' -o -iname '*.h++' -o -iname '*.i' -o -iname '*.ii' -o -iname '*.ipp' -o -iname '*.ixx' -o -iname '*.i++' -o -iname '*.c' -o -iname '*.cpp' -o -iname '*.cxx' -o -iname '*.c++' -o -iname '*.cc' -o -iname '*.py' \) > cscope.files
			silent !cscope -b -c -i cscope.files -f cscope.out
			silent !rm cscope.files
		endif

		:redraw!
		"echo 'Cscope and ctags updated'
		if exists("cscope_exists")
			cscope reset
		else
			cscope add cscope.out
		endif
	endfunction

	if has("cscope")
		set cscopetag
		set cscopequickfix=s-,c-,d-,i-,t-,e-
		if filereadable("cscope.out")
			cscope add cscope.out
			call <SID>UpdateTagsCscope()
		endif
	endif


	" Sets path for find and gf
	if isdirectory("include") && isdirectory("src")
		set path+=include/**,src/**,test/**
	endif


	" Custom mappings
	" noremap <Up> gk
	" noremap <Down> gj
	" inoremap <Up> <C-O>gk
	" inoremap <Down> <C-O>gj
	map <silent> <C-F5> :NERDTreeToggle<cr>
	map <silent> <C-F8> :TlistToggle<cr>
	nnoremap <silent> <C-F6> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>:retab<CR>
	map <silent> <C-F9> :make<cr>:copen<cr>
	map <silent> <C-F12> :call <SID>UpdateTagsCscope()<cr>
	nmap <silent> <Leader>sf :FSHere<cr>
	nnoremap <silent> <Leader>ff :FufFile<cr>
	nnoremap <silent> <Leader>fb :FufBuffer<cr>
	nnoremap <silent> <Leader>fd :FufDir<cr>
	nnoremap <silent> <Leader>fc :FufMruCmd<cr>
	nnoremap <silent> <Leader>ft :FufTag<cr>
	nnoremap <silent> <Leader>fq :FufQuickfix<cr>
	nnoremap <silent> <Leader>fl :FufLine<cr>
	nnoremap <silent> <Leader>fh :FufHelp<cr>
	map <silent> <Leader>[ :MBEbp<cr>
	map <silent> <Leader>] :MBEbn<cr>
	vnoremap > >gv
	vnoremap < <gv
	if has("autocmd")
		autocmd FileType python map <silent> <buffer> <leader><space> :w!<cr>:!python %<cr>
	endif
endif
