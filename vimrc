" Last Modified: Sat 29 Jul 2017 03:17:41 PM -03
"
" == INSTALL ==
"  1 Linux - This .vimrc/.vim requires on linux:
"    VIM 7.3
"    Python 2.7
"    cscope
"    exuberant-ctags
"    pyflakes
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
"  5. 'zR' expand all folds, 'zM' closes all
"  6. <C-p> <C-n> complete with previous/next token
"     <C-x> <C-o> complete from ctags file
"
" == SOME INSTALLED PLUGINS (updated 2011.06.23) ==
" Align - \ts, \t=        ...Align programming statements
" AutoFenc                ...Automatic Encoding Detection
" DoxygenToolkit - :Dox   ...Over function to write api documentation
" EnhancedCommentify      ...Needed by Nerd_commenter
" NERD_commenter - \c     ...Toogles comments
" NERD_tree - <C-F5>      ...Shows file tree
" fswitch - \sf           ...Toogles between companion files (.cpp/.cc/.c - .h/.hpp)
" gundo - GundoToggle     ...Toogles undo tree view
" minibufexpl             ...Shows window with buffer list
" sparkup - <C-e>         ...Zencoding. Tutorial: https://github.com/rstacruz/sparkup
" snipMate                ...Code snippets
" taglist - <C-F8>        ...Displays window with file tags (ectags)
" timestamp               ...Automatically changes timestamps upon save


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
	call pathogen#infect()
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
			"colorscheme blackboard
			let g:zenburn_high_Contrast = 1
			colorscheme zenburn
		else
			let g:zenburn_high_Contrast = 1
			colorscheme zenburn
		endif
	endif
	if has("gui_macvim")
		set clipboard=unnamed
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
		else
			if has("mac")
				set gfn=Menlo:h14
			endif
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
		autocmd Filetype c,cpp,java,python,r,matlab setlocal tabstop=8 shiftwidth=4 softtabstop=4 expandtab
		autocmd Filetype c,cpp setlocal foldmethod=syntax foldlevel=0 
		autocmd BufEnter *.{c,cpp} let b:fswitchdst = 'h,hpp' | let b:fswitchlocs = 'reg:/^\(.*\)src/\1include/'
		autocmd BufEnter *.{h,hpp} let b:fswitchdst = 'cpp,c' | let b:fswitchlocs = 'reg:/^\(.*\)include/\1src/'
		autocmd Filetype python setlocal foldmethod=indent foldnestmax=1 foldlevel=0
		autocmd BufRead *.py normal zR<cr> 
		autocmd Filetype xml,html,xhtml,css setlocal shiftwidth=2 expandtab
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

	" MozRepl integration
	function! RefreshFirefox()
		if &modified
			write
			silent !echo 'vimYo = content.window.pageYOffset;
				\ vimXo = content.window.pageXOffset;
				\ BrowserReload();
				\ content.window.scrollTo(vimXo,vimYo);
				\ repl.quit();'  |
				\ nc -w 1 localhost 4242 2>&1 > /dev/null
		endif
	endfunction

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
	noremap <silent> <C-F5> :NERDTreeToggle<cr>
	noremap <silent> <C-F8> :TlistToggle<cr>
	noremap <silent> <C-F9> :make<cr>:copen<cr>
	noremap <silent> <C-F12> :call <SID>UpdateTagsCscope()<cr>
	nnoremap <silent> <Leader>sf :FSHere<cr>
	noremap <silent> <Leader>[ :MBEbp<cr>
	noremap <silent> <Leader>] :MBEbn<cr>
	vnoremap > >gv
	vnoremap < <gv
	if has("autocmd")
		autocmd FileType python map <silent> <buffer> <leader><space> :w!<cr>:!python %<cr>
	endif
	
	" Switching DiffOrig from http://stackoverflow.com/questions/6426154/taking-a-quick-look-at-difforig-then-switching-back
	command DiffOrig let g:diffline = line('.') | vert new | set bt=nofile | r # | 0d_ | diffthis | :exe "norm! ".g:diffline."G" | wincmd p | diffthis | wincmd p
	nnoremap <Leader>do :DiffOrig<cr>
	nnoremap <leader>dc :q<cr>:diffoff!<cr>:exe "norm! ".g:diffline."G"<cr>
endif
