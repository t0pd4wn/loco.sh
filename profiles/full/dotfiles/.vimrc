set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'

"vim things --{{{
	"inputs
		"mouse behavior
		set mouse=a
		
		"mouse cursor
		let &t_SI.="\e[6 q" "SI = INSERT mode
		let &t_SR.="\e[6 q" "SR = REPLACE mode
		let &t_EI.="\e[6 q" "EI = NORMAL mode (ELSE)
		
		"insert behavior
		set backspace=indent,eol,start	
		
		"copy paste over multiple sessions
		set clipboard=unnamed

		"multi-line cursor
		" Plugin 'terryma/vim-multiple-cursors'
		" let g:multi_cursor_use_default_mapping=0

		"Default mapping
		"let g:multi_cursor_start_word_key      = '<C-n>'
		"let g:multi_cursor_select_all_word_key = '<A-n>'
		"let g:multi_cursor_start_key           = 'g<C-n>'
		"let g:multi_cursor_select_all_key      = 'g<A-n>'
		"let g:multi_cursor_next_key            = '<C-k>'
		"let g:multi_cursor_prev_key            = '<C-p>'
		"let g:multi_cursor_skip_key            = '<C-x>'
		"let g:multi_cursor_quit_key            = '<Esc>'

	"viewport rendering
		"line count
		set number
		set nuw=6
		
		"highlight current text section
		"Plugin 'junegunn/limelight.vim'
		":LimeLight 0.7
		
		"Room viewer
		"Plugin 'junegunn/goyo.vim'
		":GoYo
		
		"minimap
		Plugin 'severin-lemaignan/vim-minimap'
		let g:minimap_highlight='Visual'
		silent! au BufEnter * :Minimap

		"highlight search results
		set hlsearch
"}}}

"statusbar --{{{
	Plugin 'vim-airline/vim-airline'
	Plugin 'vim-airline/vim-airline-themes'
	let g:airline#extensions#tabline#enabled = 1
	let g:airline_powerline_fonts = 1
	let g:airline_theme='papercolor'
	
	Plugin 'drzel/vim-line-no-indicator'
	let g:line_no_indicator_chars = ['⎺', '⎻', '─', '⎼', '⎽'] " on macOS
	
	"let g:airline_section_x = '%{&filetype}'
	"let g:airline_section_y = '%#__accent_bold#%{LineNoIndicator()}%#__restore__#'
	"let g:airline_section_z = '%2c'
"}}}

	"fold
	Plugin 'pseewald/anyfold'
	":AnyFoldActivate
	filetype plugin indent on " required
	syntax on                 " required
	autocmd Filetype * AnyFoldActivate               " activate for all filetypes
	" or
	" autocmd Filetype <your-filetype> AnyFoldActivate " activate for a specific filetype
	set foldlevel=0  " close all folds or 99 for open
	"hi Folded term=underline


"code specific
	"autocomplete
	" Plugin 'ycm-core/YouCompleteMe'
	
	"html5 / javascript
	" Plugin 'othree/html5.vim'
	" Plugin 'othree/yajs.vim'

"colorschemes
	Plugin 'sickill/vim-monokai'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" Theme
	silent! syntax enable
	silent! colorscheme monokai
