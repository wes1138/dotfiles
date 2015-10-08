" configuration {{{
" web browser:
let s:browser = "qutebrowser"
" use my strange key bindings?
let s:usestrangemappings = 1
" NOTE -- There are nevertheless a few keybindings enabled for features
" like the SpellFix functions.
" }}}
" Global default settings {{{
set nocompatible
set winaltkeys=no   " disable alt mapping straight to the menu keys
set history=1000
set ruler
set noshowcmd   " don't display commands as you type
set incsearch
set selection=exclusive
" Search options
set ignorecase
set smartcase
" Indentation settings
set tabstop=4
set shiftwidth=4
set smarttab
set autoindent
set ww=h,l,b,s,<,>,[,]
" File format
set fileformats=unix,dos
set fileformat=unix  " make this the default for empty buffers.
" Buffers
" set switchbuf+=usetab,newtab
" set switchbuf+=useopen,usetab,split
" set switchbuf+=useopen,usetab
" switchbuf turned off is best for quickfix, but sometimes I want to follow
" the location list around:
function s:toggleSwitchBuf()
	if &switchbuf == ""
		set switchbuf=useopen,usetab
	else
		set switchbuf=""
	endif
endfunction
command TS call s:toggleSwitchBuf()

" make normal-K use vim help instead of man pages:
set keywordprg=""
" ack is more convenient than grep for most things:
set grepprg=ack
" probably not a big deal, but for power-saving, write to
" the swap file less often:
set updatecount=350
set updatetime=120000
" make new windows appear below/right of existing:
set splitbelow
set splitright

" to get rid of delay when, for example, opening a new line after hitting
" escape:
set ttimeoutlen=150
" If you have a really slow ssh connection, this might cause arrow keys (which
" start with escape) to not work.  But I seldom (if ever) use those...
" }}}
" Borrow a few things from standard config {{{
" from $VIMRUNTIME/mswin.vim {{{
" source $VIMRUNTIME/mswin.vim
set backspace=indent,eol,start whichwrap+=<,>,[,]
vnoremap <C-C> "+y
map <C-V>		"+gP
cmap <C-V>		<C-R>+
noremap <C-Q>	<C-V>
noremap! <C-V>  <C-R>+

" Alt-Space is System menu
if has("gui")
	noremap <M-Space> :simalt ~<CR>
	inoremap <M-Space> <C-O>:simalt ~<CR>
	cnoremap <M-Space> <C-C>:simalt ~<CR>
endif
" }}}
" reasonable stuff from vimrc_example {{{
if has('mouse')
	set mouse=a
endif

if &t_Co > 2 || has("gui_running")
	syntax on
	set hlsearch
endif

if has("autocmd")

  " Enable file type detection.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

"}}}
" }}}
" Global variables"{{{
if has('win32') || has('win64')
	let $VIMHOME = expand('~/vimfiles')
else
	let $VIMHOME = expand('~/.vim')
endif
"}}}
" Package/plugin Management"{{{
filetype off
call pathogen#infect()
"}}}
" Appearance, syntax, colors, folding {{{

syntax enable
" set light / dark background based on time of day:
if (strftime("%H") > 16 || strftime("%H") < 6 || !has("gui_running"))
	set background=dark
else
	set background=light
endif

if has("gui_gtk2")
	set guifont=Inconsolata\ Medium\ 12
elseif has("gui_win32")
	set guifont=Consolas:h11:cANSI
endif

if has("gui_running")
	colorscheme solarized_hc
else
	" use solarized only for xterm, or xterm running inside of tmux (which has
	" &term=screen, hence the strange-looking check):
	if &term != "linux" && (expand("$XTERM_VERSION") != "$XTERM_VERSION"
				\ || filereadable(expand("~/.usecolor")))
		" For some reason, when over ssh, setting termtrans=1 is
		" not a good idea.
		let g:solarizedhybrid_xterm = 1
		"if !filereadable(expand("~/.usecolor"))
			set t_Co=256
			let g:solarized_termcolors=&t_Co
			let g:solarized_termtrans=1
		"endif
		colorscheme solarized_hc
	endif
	" for other situations (e.g. linux terminal, or some ssh
	" sessions...) we'll just leave it out.
endif
" for changing the font:
if has('win32') || has('win64')
	nnoremap <C-Up> :silent! let &guifont = substitute(
	 \ &guifont,
	 \ ':h\zs\d\+',
	 \ '\=eval(submatch(0)+1)',
	 \ '')<CR><CR>
	nnoremap <C-Down> :silent! let &guifont = substitute(
	 \ &guifont,
	 \ ':h\zs\d\+',
	 \ '\=eval(submatch(0)-1)',
	 \ '')<CR><CR>
else
	nnoremap <C-Up> :silent! let &guifont = substitute(
	 \ &guifont,
	 \ '\d\+$',
	 \ '\=eval(submatch(0)+1)',
	 \ '')<CR><CR>
	nnoremap <C-Down> :silent! let &guifont = substitute(
	 \ &guifont,
	 \ '\d\+$',
	 \ '\=eval(submatch(0)-1)',
	 \ '')<CR><CR>
endif

" Remove toolbar and menu bar, and make text tabs, like terminal vim.
set guioptions-=T
set guioptions-=m
set guioptions-=r
set guioptions-=L
set guioptions-=e

" blinking cursor is a little dagger that stabs me with every passing second,
" mocking my lack of productivity and reminding me that death is growing ever
" closer.  Turn it off:
set guicursor+=n:block-Cursor/lCursor-blinkon0,i:blinkon0-ver25-Cursor/lCursor

" set default fold method:
set foldmethod=marker

" HTML output options

let g:html_number_lines = 1
let g:html_dynamic_folds = 1

" }}}
" Functions {{{
function s:delsearch() "{{{
	" wrapper to turn off hlsearch after a d/ operation.
	let sterm = input("d/")
	if (sterm == "")
		return
	endif
	silent exe "normal! d/" . sterm . "\<CR>:noh\<CR>"
	" NOTE -- if this flickers, just set a mark with plain old search
endfunction
"}}}
function! s:GetBufferList() "{{{
	redir =>buflist
	silent! ls
	redir END
	return buflist
endfunction
"}}}
function! s:ToggleList(bufname, pfx) "{{{
	let buflist = s:GetBufferList()
	for bufnum in map(filter(split(buflist, '\n'), 'v:val =~ "'.a:bufname.'"'),
				\ 'str2nr(matchstr(v:val, "\\d\\+"))')
		if bufwinnr(bufnum) != -1
			exec(a:pfx.'close')
			return
		endif
	endfor
	if a:pfx == 'l' && len(getloclist(0)) == 0
		echohl WarningMsg
		echo "Location List is Empty."
		echohl None
		return
	endif
	let winnr = winnr()
	exec(a:pfx.'open')
	if winnr() != winnr
		wincmd p
	endif
endfunction
"}}}
function s:pushMentalStack() "{{{
	if !exists("g:mental_stack_tmpfile")
		let g:mental_stack_tmpfile = tempname()
	endif
	let sitem = input("Push: ")
	if sitem == ""
		return
	endif
	" vim script doesn't have a clean way to append to a file, so:
	let tmpList = []
	if filereadable(g:mental_stack_tmpfile)
		let tmpList = readfile(g:mental_stack_tmpfile)
	end
	call add(tmpList,expand("%") . ":" . line(".") . ":" . sitem)
	call writefile(tmpList,g:mental_stack_tmpfile)
endfunction
"}}}
function s:isLocListActive() "{{{
	let buflist = s:GetBufferList()
	for bufdesc in filter(split(buflist,'\n'), 'v:val=~"Location List"')
		if bufdesc =~ '\d\+\_.%a'
			return 1
		endif
	endfor
	return 0
endfunction
"}}}
function s:popMentalStack(mode) "{{{
	" TODO: save the last item popped in a variable so that we can
	" undo a single pop?
	let tlist = []
	if exists("g:mental_stack_tmpfile")
		let tlist = readfile(g:mental_stack_tmpfile)
	endif
	if tlist == []
		echohl WarningMsg
		echon "Stack is empty"
		echohl None
		return
	endif
	if a:mode == 0
		let indxToRemove = len(tlist) - 1
	else
		" now dump the contents of the stack into a numbered list and
		" let the user select an item to remove.
		let tlPrompt = deepcopy(tlist)
		call map(tlPrompt,'v:key . ". " . v:val')
		let prompt = "Select item to pop:\n" . join(tlPrompt,"\n") . "\n"
		let indxToRemove = input(prompt)
		if indxToRemove == ""
			return
		endif
	endif
	echo "Popped: " . remove(tlist,indxToRemove)
	" now write back to the file.
	call writefile(tlist,g:mental_stack_tmpfile)
	" One would hope that popping a stack would run in O(1) time.
	" I guess this isn't so bad, since we are drawing it all the time anyway.
	return
endfunction
"}}}
function s:showMentalStack() "{{{
	" load the mental stack into the location list.
	let tlist = []
	if exists("g:mental_stack_tmpfile")
		let tlist = readfile(g:mental_stack_tmpfile)
	endif
	if tlist == []
		echohl WarningMsg
		echon "Stack is empty"
		echohl None
		return
	endif
	call setloclist(0,[]) " first clear it out.
	for ditem in tlist
		laddexpr ditem
	endfor
	" call s:ToggleList("Location List", 'l')
	lopen
endfunction
"}}}
" save mental stack to a (non-temp) file"{{{
function s:saveStackToFile(...)
	if !exists("g:mental_stack_tmpfile")
		echohl WarningMsg
		echo "No items in stack."
		echohl None
		return
	endif
	if a:0 > 0
		let stackfilename = a:1
	else
		let stackfilename = ".VIMSTACK"
	endif
	silent! execute "!cp '" . g:mental_stack_tmpfile . "' '" . stackfilename . "'"
	echo "Stack saved to " . stackfilename
endfunction
"}}}
" restore mental stack from file"{{{
function s:readStackFromFile(...)
	if !exists("g:mental_stack_tmpfile")
		let g:mental_stack_tmpfile = tempname()
	endif
	if a:0 > 0
		let stackfilename = a:1
	else
		let stackfilename = ".VIMSTACK"
	endif
	silent! execute "!cp '" . stackfilename . "' '" . g:mental_stack_tmpfile . "'"
	echo "Stack read from " . stackfilename
endfunction
"}}}
" cycle the line number options"{{{
function s:cycleLineNumbers()
	let lnopts = {'00': 'number', '10': 'rnu | setlocal nonumber',
				\'01': 'number', '11': 'nornu | setlocal nonumber'}
	exe 'setlocal ' . lnopts[&number . &rnu]
endfunction
"}}}
" python calculator: saves result to default register {{{
function s:pyCalculator(whichMode)
	if !has("python")
		echo "Vim must be compiled with +python to use this function."
		return
	endif
	if a:whichMode == 0 || a:whichMode == 1 "normal or insert mode
		let sexpr = input("Python expr: ")
		if sexpr == ""
			return
		endif
	elseif a:whichMode == 2 "visual mode
		let tempreg = @a
		normal! gv"ay
		let sexpr = @a
		let @a = tempreg
	endif
	let regsave = @@
	python import vim
	exe "python vim.command('let @@ = \"' + str(" . sexpr . ") + '\"')"
	if a:whichMode == 1 "insert mode
		normal! p
	elseif a:whichMode == 0
		exe 'normal! :echo "' . @@ . "\"\<CR>"
		return
		" note that we *don't* restore the register in this case.
	else
		normal! gvp
	endif
	let @@ = regsave
	" Note: to expand the contents of @", we invoke the echo
	" command from exe, rather than by itself.
endfunction
" }}}
" inline python calculator {{{
function s:getLastArithmetic()
	" returns a list of two integers representing the start
	" and end of the expression, in terms of columns on the
	" current line.  The first element will be -1 if no such
	" expression could be found. The function looks for the
	" nearest expression to the left, and if none is found,
	" will search for the first expression to the right.
	let exprpat = '\(\d\|-\|\~\|(\)' .
		\ '\(\d\|\.\|+\|-\|*\|/\||\|\^\|<<\|>>\|%\|\~\|(\|)\|\s\)\+\(\S\)\@!'
	let colsave = col('.')
	call search(exprpat,'bc',line('.'))
	let exprstart = col('.') - 1 " a failed search won't move the cursor.
	" now restore the cursor to where it was before:
	call cursor(line('.'),colsave)
	let cline = getline('.')[exprstart :]
	" now move mstart to the beginning of the expression (if the
	" match was to the right of the cursor, due to no matches left.)
	let mstart = match(cline,exprpat)
	let mend = (mstart==-1) ? -1 : matchend(cline,exprpat,mstart)
	return (mstart==-1) ? [mstart,mend] : 
				\ [mstart + exprstart + 1, mend + exprstart]
endfunction
function s:pyCalcInline(whichMode)
	if !has("python")
		echo "Vim must be compiled with +python to use this function."
		return
	endif
	" TODO: include a \(\.\d+\) into the expression?  I hate floating
	" point too, but if it wont' cause harm, maybe it is worth it.
	if a:whichMode == 2
		let tempreg = @a
		normal! gv"ay
		let mexpr = @a
		let @a = tempreg
	else
		let ebnds = s:getLastArithmetic()
		if ebnds[0] == -1
			let mexpr = input("Python expr: ")
			if mexpr == ""
				return
			endif
		else
			" careful: have to switch to 0-based indexes:
			let mexpr = getline('.')[ebnds[0]-1 : ebnds[1]-1]
		endif
	endif
	let regsave = @@
	python import vim
	exe "python vim.command('let @@ = \"' + str(" . mexpr . ") + '\"')"
	" now, what to do with @@?  Depends on the mode.
	if a:whichMode != 1 " normal or visual mode
		exe 'normal! :echo "' mexpr . '=' . @@ . "\"\<CR>"
		return
	endif
	" check to see if cursor is in between:
	if ebnds[0] <= col('.') && col('.') <= ebnds[1]
		call cursor(line('.'), ebnds[1])
		let @@ = ' = ' . @@
	endif
	normal! p
	let @@ = regsave
endfunction
" }}}
" open quickfix in a new tab {{{
function s:tabOpenQF()
	tabnew
	copen
	wincmd w
	q
	" and you should be left with the quickfix window.
endfunction
" }}}
" search for keyword under cursor with vimgrep {{{
function s:vgrepForKW()
	exe 'vimgrep! /\<' . expand('<cword>') . '\>/j *'
	copen 20
endfunction
" }}}
" search for keyword under cursor, or supplied pattern with grepprg {{{
" a:1 -- jump
" a:2 -- use quickfix instead of location
" a:3 -- pattern (defaults to <cword>)
function s:grepForKW(...)
	let jmp="!"
	let location="l"
	if a:0 && a:1
		let jmp = ""
	endif
	if a:0 > 1 && a:2
		let location = ""
	endif
	let osp = &shellpipe
	let &shellpipe = '>'
	if a:0 > 2
		let pattern = a:3
	else
		let pattern = expand('<cword>')
	endif
	silent exe location . "grep" . jmp . " -w '" . pattern . "'"
	let &shellpipe = osp
	let cheight = &lines / 4
	if location == ""
		let location = "c"
	endif
	if a:0 == 0 || a:1 == 0
		exe location . "open " . cheight
		redraw!
	endif
endfunction
" }}}
" highlight keyword under cursor without jumping {{{
function s:hlCurrentWord()
	" this will work mod 2?  There is one potentially
	" confusing case in which you have something else highlighted
	" and then you run this command, and find it just turned off
	" highlighting.  But then you will naturally start to bang on
	" the keyboard, which will actually fix the issue :D
	if &hlsearch == 1
		set nohlsearch
		return
	endif
	exe 'let @/ = "\\V\\<' . expand('<cword>') . '\\>"'
	set hlsearch
	redraw
	" not sure why redraw is needed, but it seems to be the case.
endfunction
" }}}
" open cWORD in browser {{{
function s:openInBrowser()
	let cwURL = expand('<cWORD>')
	" if cwURL !~ '\<http\(s\)\?://[a-zA-Z0-9_.~?/&%-]\+\>'
	" 	let cwURL = ""
	" endif
	" since many browsers run a search for non-url parameters, it's probably
	" safe to just make sure the string doesn't have quotes:
	if cwURL =~ '\(''\|\"\)'
		let cwURL = ""
	endif
	let cwURL = escape(cwURL,'#%')
	exe "!(" . s:browser . " '" . cwURL . "' &> /dev/null &)"
endfunction
" }}}
" }}}
" Keyboard mappings"{{{
" NOTE -- with some effort, you might be able to get alt key mappings
" to work with xterm's metasendsescape enabled by doing this:
" set <M-,>=,
" for every alt key that you want to map... *sigh*
" navigation "{{{
" regular mode:
if s:usestrangemappings " {{{
noremap e i
noremap k j
noremap i k
noremap j h
noremap h 0
noremap ; $
noremap 9 <C-E>
noremap 0 <C-Y>
noremap <C-k> }
noremap <C-i> {
" bring back useful commands we just overwrote:
nnoremap q e
vnoremap q e
nnoremap Q q
" NOTE -- you have gQ which is a better version of Q anyway
noremap <C-p> <C-i>
noremap <M-o> <C-i>
" move a quarter of a screen up / down:
function QuarterScreen(direction)
	return (&lines / 4) . a:direction
endfunction
" NOTE -- conflicts with latex mappings.
nnoremap <expr> <M-d> QuarterScreen("j")
nnoremap <expr> <M-u> QuarterScreen("k")
" jump to the middle column:
function s:MiddleCol()
	let ncols = &tw
	if ncols == 0
		let ncols = winwidth(0)
	endif
	call setpos(".",[0,line("."),ncols/2,0])
endfunction
" Note: by default, zl will scroll right, which I never do.
nnoremap <silent> zl :call <SID>MiddleCol()<CR>
function s:GotoLine()
	let gline = input("G:")
	if (gline == "")
		return
	endif
	exe "normal! " . gline . "G"
	normal! zv
	normal! zz
endfunction
nnoremap <S-M-g> :call <SID>GotoLine()<CR>
" remove these from select mode:
sunmap e
sunmap k
sunmap i
sunmap j
sunmap h
sunmap ;
sunmap 9
sunmap 0
endif " }}}
nnoremap ]q :cnext<CR>zv
nnoremap [q :cNext<CR>zv
nnoremap ]w :lnext<CR>zv
nnoremap [w :lNext<CR>zv
"}}}
" insert / command line mode "{{{
if s:usestrangemappings
noremap! <M-j> <Left>
noremap! <M-l> <Right>
noremap! <M-i> <Up>
noremap! <M-k> <Down>
noremap! <M-;> <End>
" make command mode more like your inputrc:
cnoremap <M-h> <Left>
cnoremap <M-j> <Down>
cnoremap <M-k> <Up>
cnoremap <S-M-h> <Home>
cnoremap <M-b> <C-Left>
cnoremap <M-w> <C-Right>
cnoremap <M-,> <C-w>

" can't get any of the <M-C-x> maps to be
" recognized : (  Only works for control keys (say <M-C-Left>)
endif
"}}}
" editing"{{{
if s:usestrangemappings
noremap! <M-o> <BS>
noremap! <S-M-o> <Del>
nnoremap <Return> o
nnoremap <Space> a 
nnoremap <M-,> BdW
nnoremap <M-.> dW
inoremap <M-,> <C-w>
inoremap <M-.> <C-O>dw
nnoremap ,q gwap

nnoremap <C-Return> <Return>
" The above seems to only work in gvim, so add something random:
nnoremap <M-1> <Return>

" making a new paragraph break at the current sentence:
nnoremap ,m l(dT.i<CR><CR><Esc>gwap
" TODO:  This doesn't appear to work if the sentence you are breaking
" at starts in the first column.  The backwards delete fails, which
" seems to prevent the rest of the sequence from moving on...
" It also fails if the sentence before ends in a question mark instead
" of a period.

" append to a *word*
nnoremap <M-n> ea

" For replacing text and NOT saving it into a buffer / changing
" the current register:
vnoremap R "_dP

" There is some strangeness with <c-q> in terminals. we'll use something else
" for visual block mode:
nnoremap ,v <C-v>

" Experimental: kill / change until end of sentence.
" Rationale: if the end of the sentence is on the same line as you are typing,
" then there isn't a big issue with 'dt.' or 'ct.'.  The problem is that when
" the end of your sentence lies on a different line, these no longer work, and
" there aren't a lot of good alternatives. 'd)' sometimes kills more than you
" want: it goes all the way to the beginning of the next sentence.  The other
" option is 'd/\.' which is (a) hard to type, and (b) leaves you with the
" chore of unsetting the search highlighting.  So I propose the following:
function s:KillTilEOS(killspace)
	if a:killspace == 1 && getline(".")[col(".") - 2] == ' '
		normal! h
	endif
	if search("[.?!]\\|:)\\|: )\\|o\\.o\\|@_@\\|:D\\|\\n\\n","sW")
		normal! d``
	endif
endfunction
nnoremap <silent> d. :call <SID>KillTilEOS(1)<CR>
nnoremap <silent> c. :call <SID>KillTilEOS(0)<CR>i
" TODO: you should also implement something like this for the ,m mapping
" to make it more flexible (currently only works for sentences ending with
" a period...
endif

" spelling completion {{{
" insert mode: try to fix the last spelling mistake
" and the return to last edit position (in insert mode).
" normal mode: just fix the next / previous spelling error.
" NOTE: hitting <M-a> will now cycle through the
" list of spelling options.  This variable keeps track of where you are:
let g:CurSpellIndex = 2
function SpellFixInit()
	" reset current spell index to 2:
	let g:CurSpellIndex = 2
	let cline = getline(".")
	let llen = len(cline)
	let cmdbase = "\<C-G>u\<Esc>[s1z=`]"
	if col(".") > llen
		return cmdbase . "a"
	endif
	return cmdbase . "i"
endfunction
function SpellFixAgain(mode)
	let cmd = ""
	if a:mode == 0 " insert mode
		let cmd = "\<Esc>"
		let cline = getline(".")
		let llen = len(cline)
	endif
	let cmd = cmd . "u" . g:CurSpellIndex . "z="
	let g:CurSpellIndex = g:CurSpellIndex + 1
	" TODO: the marks don't come out quite as nicely as they do for
	" SpellFixInit(), but it isn't so bad this way.
	if a:mode == 0
		if col(".") > llen
			let cmd = cmd . "``a"
		else
			let cmd = cmd . "``i"
		endif
	endif
	return cmd
endfunction
inoremap <expr> <M-s> SpellFixInit()
" alt key sends an escape key for most terminals x_x
" so as a workaround, we define an alternate mapping:
if !has("gui_running") && (&term == "linux" ||
			\	(&term == "screen" &&
			\	(expand("$XTERM_VERSION") == "$XTERM_VERSION")))
	inoremap <expr> ,w SpellFixInit()
	" we also have an alternate mapping for killing a word backwards:
	inoremap ,, <C-w>
endif
" NOTE the strange check is to avoid defining the mappings for
" tmux running inside of xterm.
nnoremap <silent> <M-s> :let<Space>g:CurSpellIndex=2<CR>[s1z=
nnoremap <silent> <M-S-s> :let<Space>g:CurSpellIndex=2<CR>]s1z=
inoremap <expr> <M-a> SpellFixAgain(0)
nnoremap <expr> <M-a> SpellFixAgain(1)
inoremap <S-M-a> <Esc>uz=
nnoremap <S-M-a> uz=
" Note: I want to put a `]a at the end of the M-a mapping, but it
" has no effect, since those keys are spent while the spelling suggestion
" list is showing.  You could keep a counter and go through one by one, but
" I think that is getting kind of insane, and isn't clear that it will be
" useful.

if s:usestrangemappings
" Capitalization:
inoremap <M-h> <Esc>bgUlea

" common spelling mistakes (especially on laptop with mouse-nub.)
" in general, this might not be appropriate for the global vimrc,
" however, I think this is uncommon enough in any progrmaming setting
" so we'll leave it be until, or unless it becomes an issue.
inoreabbr tat that
inoreabbr te the
inoreabbr teh the
inoreabbr th the
inoreabbr dont don't
" inoreabbr dont' don't
" this will go a little wrong, unless you have
" setlocal iskeyword+=' which I'm not sure is always a good idea.
" this will fix it, but it is kind of strange to have two of them
" happening back to back as you type:
inoreabbr don't' don't
inoreabbr wont won't
inoreabbr won't' won't
inoreabbr youre you're
inoreabbr Im I'm
inoreabbr I'm' I'm
inoreabbr im I'm
inoreabbr answerd answered
endif
" }}}

" }}}
" Miscellaneous "{{{
if s:usestrangemappings " {{{
noremap z. zz
noremap zz za
noremap ' ;
noremap ,, ,
vnoremap > >gv
vnoremap < <gv
sunmap z.
sunmap zz
sunmap '

nnoremap <silent> d/ :call <SID>delsearch()<CR>
vnoremap <M-/> <Esc>/\%V
" TODO: make cc map to del search but leave you in insert mode.
" NOTE -- cc is a synonym of the more common S, after all.
" TODO: it would be neat if you could somehow capture the entire thing
" that dc did as a single action so that you could repeat it with '.'

" insert current time:
inoremap <S-M-T> <C-R>=strftime("%c")<CR>
" toggle search highlight
" nnoremap <silent> <F4> :set hls!<CR>
nnoremap <silent> <F4> :noh<CR>
nnoremap <silent> <S-F4> :set hls<CR>
nnoremap <silent> <F8> :call <SID>hlCurrentWord()<CR>
" update (as opposed to write)
nnoremap ,s :update<CR>
nnoremap <silent> <F11> :call <SID>cycleLineNumbers()<CR>
command SR syn sync fromstart
endif " }}}

" Plugins"{{{
if s:usestrangemappings
" Python calculator:
nnoremap <S-F3> :call <SID>pyCalculator(0)<CR>
inoremap <S-F3> <C-O>:call <SID>pyCalculator(1)<CR>
vnoremap <silent> <S-F3> :call <SID>pyCalculator(2)<CR>
nnoremap <F3> :call <SID>pyCalcInline(0)<CR>
inoremap <F3> <C-O>:call <SID>pyCalcInline(1)<CR>
vnoremap <F3> :call <SID>pyCalcInline(2)<CR>
" Pygmentize
" TODO. change this mapping to a command? You will need different for each
" file type.
" New version using the system() function.  Much cleaner!
" References:
" http://stackoverflow.com/questions/2273780/how-can-i-filter-the-content-of-a-register-in-vim
function s:getPygmentOpts()
	let regsave = @a
	normal! gv"ay
	let pygcmd = "pygmentize -l "
	" mapping of extension to lexers?
	" get lexer from file extension of current buffer:
	let lexer = expand("%:e")
	" NOTE -- there is now a -g option, which claims to "guess" the
	" lexer from the input.
	" we almost exclusively use this with latex, so just leave this
	" as the default:
	" let fmtlatex = " -f latex -O mathescape=True,linenos=True"
	let fmtlatex = " -f latex -O mathescape=True"
	" formatters = {"tex": "latex"}
	let retval = pygcmd . lexer . fmtlatex
	let @+ = system(retval,@a)
	let @a = regsave
endfunction
vnoremap ,P :call <SID>getPygmentOpts()<CR>
endif
"}}}
" window management "{{{
if s:usestrangemappings
" get rid of preview window when not needed:
nnoremap <S-M-b> :pclose<CR>
inoremap <S-M-b> <C-o>:pclose<CR>
" shortcut for quit without save.
command CL q!
command CLL qall!
command LCD lcd %:p:h
command EN echo expand("%:p")
command -nargs=1 -complete=file DS vertical diffsplit <args>
command -nargs=1 -complete=file VV vertical sview <args>
nnoremap <S-M-x> <C-W><C-Q>
nnoremap ,x :x<CR>
nnoremap ,X :qall<CR>
" quickfix / location list management
nnoremap <silent> <S-M-c> :call <SID>ToggleList("Quickfix List", 'c')<CR>
nnoremap <silent> <S-M-l> :call <SID>showMentalStack()<CR>
nnoremap <silent> <M-{> :call <SID>pushMentalStack()<CR>
nnoremap <silent> <M-}> :call <SID>popMentalStack(1)<CR>
nnoremap <silent> <M-+> :call <SID>readStackFromFile()<CR>
command -complete=file -nargs=? SaveStack call s:saveStackToFile(<f-args>)
command -complete=file -nargs=? LoadStack call s:readStackFromFile(<f-args>)
command CO call s:tabOpenQF()
" grep for what is under the cursor.  Be careful not to do this
" in a directory like ~/ that might have a ton of other stuff
nnoremap ,V :call <SID>vgrepForKW()<CR>
nnoremap <silent> ,A :call <SID>grepForKW()<CR>
nnoremap <silent> ,,A :call <SID>grepForKW(1)<CR>
nnoremap <silent> ,T :call <SID>grepForKW(0,0,"(TODO\\\|FIXME\\\|XXX)")<CR>
nnoremap <silent> ,,T :call <SID>grepForKW(1,0,"(TODO\\\|FIXME\\\|XXX)")<CR>
" finally expose function through a command:
command -nargs=* FFIND call s:grepForKW(<f-args>)
command -nargs=1 FIND call s:grepForKW(0,0,<f-args>)
" more familiar mappings for moving between windows
nnoremap <S-Space> <C-W>w
nnoremap <S-BS> <C-W>W
nnoremap <C-Space> <C-PageDown>
nnoremap <C-BS> <C-PageUp>
" C/S with space don't work in a terminal.
nnoremap <S-M-n> <C-PageDown>
nnoremap <S-M-p> <C-PageUp>
" <C-W> is hard to type.  This is not perfect, as it does
" seem to work when typing it twice consecutively.
nnoremap <M-w> <C-W>
" try some for insert mode as well.
inoremap <C-Space> <C-PageDown>
inoremap <C-BS> <C-PageUp>
endif
"}}}
"}}}
" comment / uncomment / surroundings "{{{
function s:cstyleSetup()
	let b:comment_leader = '// '
	let b:surround_99 = "#if 0\n\r\n#endif"
endfunction

function s:texstyleSetup()
	let b:comment_leader = '% '
	let b:surround_113 = "``\r''"
	let b:surround_99 = "\\ignore {\n\r\n}"
endfunction

" default surroundings:
" these globals will be overridden by the b:var variety
" so that the more specific types take effect as needed.
let g:surround_113 = "\"\r\""
let g:surround_99 = "/*\r*/"
if !exists("g:comment_autocmds_defd")
	au FileType haskell,vhdl,ada let b:comment_leader = '-- '
	au FileType vim let b:comment_leader = '" '
	au FileType c,cpp,java,javascript,php call s:cstyleSetup()
	au FileType sh,make,python,conf,perl let b:comment_leader = '# '
	au FileType tex call s:texstyleSetup()
	au FileType mail let b:comment_leader = '> '

	let g:comment_autocmds_defd = 1
endif
" comment/uncomment:
if s:usestrangemappings
vnoremap <silent> ,c :<C-B>sil <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<CR>/<CR>:noh<CR>
vnoremap <silent> ,u :<C-B>sil <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<CR>//e<CR>:noh<CR>
vmap ,C <Plug>VSurroundc
" duplicate a line, commenting the original:
nnoremap yD "zyy^i<C-R>=b:comment_leader<CR><Esc>"zp

" quotes:
nmap <M-'> <Plug>Ysurroundewq
xmap <M-'> <Plug>VSurroundq
imap <M-'> <Plug>Isurroundq
" parens and braces:
xmap <M-g> <Plug>VSurround}
imap <M-g> <Plug>Isurround}
nmap <M-g> <Plug>Ysurroundew}
xmap <M-p> <Plug>VSurround)
imap <M-p> <Plug>Isurround)
nmap <M-p> <Plug>Ysurroundew)
xmap <M-]> <Plug>VSurround]
imap <M-]> <Plug>Isurround]
nmap <M-]> <Plug>Ysurroundew]
endif
"}}}
" Experimental"{{{
if s:usestrangemappings
noremap <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'. synIDattr(synID(line("."),col("."),0),"name") . "> lo<". synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" Make the behavior of Y analogous to D
nnoremap Y y$

" open a new email message:
nnoremap <F12> :sp ~/temp_svimtp_message.mail<CR>A
" TODO: make a proper temp file.

" Start some function braces (bash,C,php,etc.). NOTE -- strange
" ordering is so we don't mess up folds.
inoremap <S-M-g> }<Esc>i{<CR><Esc>O
" easier window movement:
nnoremap <M-j> <C-w>h
nnoremap <M-l> <C-w>l
nnoremap <M-k> <C-w>j
nnoremap <M-i> <C-w>k
" NOTE -- l,j conflict with after/tex.vim

nnoremap ,b :call <SID>openInBrowser()<CR><CR>
endif
"}}}
"}}}
" Backup & session settings"{{{
set nobackup
set nowritebackup
" if vim is opened without a file, treat it kind of like scratch
" and don't set a swapfile; if it exists, it prevents you from
" editing *scratch* without annoying errors. We'll also set the
" default filetype to text, since that is what we almost always
" want with a blank buffer.
if expand("%") == ''
    setlocal noswapfile
	setlocal filetype=text
endif
set sessionoptions+=winpos,resize
"}}}
" Package configuration"{{{
" supertab configuration
let g:SuperTabDefaultCompletionType = "context"
let g:SuperTabNoCompleteAfter = ["'",'\s']
function s:cycleSupertabCompletionType()
	let stopts = {'<c-p>': '<c-x><c-o>', '<c-x><c-o>': '<c-p>'}
	let g:SuperTabContextDefaultCompletionType = 
				\ stopts[g:SuperTabContextDefaultCompletionType]
endfunction
let g:haddock_docdir="/usr/share/doc/ghc/html/"
if s:usestrangemappings
inoremap <F12> <C-O>:call <SID>cycleSupertabCompletionType()<CR>
endif
"}}}
" Autocommands"{{{
if !exists("autocommands_loaded")
	let autocommands_loaded = 1
	autocmd BufNewFile  *.tex	0r $VIMHOME/skeletons/skeleton.tex
	autocmd BufNewFile  *.mkd	0r $VIMHOME/skeletons/skeleton.mkd
	autocmd BufNewFile  *.mail	0r $VIMHOME/skeletons/skeleton.mail
	autocmd BufNewFile  *.vim	0r $VIMHOME/skeletons/skeleton.vim
	autocmd BufNewFile  *.sh	0r $VIMHOME/skeletons/skeleton.sh
	autocmd BufNewFile  Makefile	0r /home/wes/.vim/skeletons/skeleton.make
	autocmd BufEnter *.hs compiler ghc
	autocmd BufEnter /usr/share/doc/NTL/* set ft=cpp
endif
"}}}
