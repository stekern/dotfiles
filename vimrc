set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
"Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
" Git plugin not hosted on GitHub
"Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
"Plugin 'file:///home/gmarik/path/to/plugin'

" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
Plugin 'ascenator/L9', {'name': 'newL9'}

" All of your Plugins must be added before the following line
" My plugins
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/syntastic'
Plugin 'aperezdc/vim-template'
Plugin 'valloric/youcompleteme'
Plugin 'LaTeX-Box-Team/LaTeX-Box'
Plugin 'chriskempson/base16-vim'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'bling/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'tpope/vim-fugitive'
Plugin 'pangloss/vim-javascript'
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




" * * * * * * * * * * * * * * * "



" *** VIM SETTINGS ***

" General
set clipboard=unnamed " Enables system clipboard (?)
set number " Enable line number
set ruler " Enable ruler
set backspace=indent,eol,start " Make backspaces better
set showmatch " Shows matching brackets
set undofile " Tell it to use an undo file
set undodir=~/.vimundo/ " Set a directory to store the undo history
set incsearch " Show the next match while entering a search
set hlsearch " Highlighting search matches
syntax on " Enable syntax
colorscheme base16-google-dark
set background=dark
set autochdir
set encoding=utf-8

" Clear highlighting on escape in normal mode
nnoremap <esc> :noh<return><esc>
nnoremap <esc>^[ <esc>^[

" Disable arrow keys in NORMAL mode
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>

" Keep selection after indenting
:vnoremap < <gv
:vnoremap > >gv

" Scroll more lines with CTRL-e and CTRL-Y
nnoremap <C-e> 3<C-e>
nnoremap <C-y> 3<C-y>

" Cycle through panes using TAB and autochange dir
map <Tab> <C-w>w:cd %:p:h<CR>:<CR>

" Change tabs using H and L
nnoremap H gT
nnoremap L gt

" Indentation settings
autocmd Filetype html setlocal ts=2 sw=2 expandtab
autocmd Filetype scss setlocal ts=2 sw=2 expandtab
autocmd Filetype css setlocal ts=2 sw=2 expandtab
autocmd Filetype ruby setlocal ts=2 sw=2 expandtab
autocmd Filetype eruby setlocal ts=2 sw=2 expandtab
autocmd Filetype javascript setlocal ts=2 sw=2 expandtab

" Change cursor if running vim in iTerm
if $TERM_PROGRAM =~ "iTerm"
    let &t_SI = "\<Esc>]50;CursorShape=1\x7" " Vertical bar in insert mode
    let &t_EI = "\<Esc>]50;CursorShape=0\x7" " Block in normal mode
endif

" Set default TeX flavor
let g:tex_flavor = 'latex' " .tex files are usually written in LaTeX

" Compile .tex and open corresponding .pdf when saving a .tex file
autocmd BufWritePost *.tex silent exec '!(latexmk '.shellescape('%').' -pdf && open -g -a Skim '.shellescape('%:r').'.pdf) >/dev/null 2>&1' | redraw!

" Auto compile and run .py files
autocmd filetype python nnoremap <F5> :w <bar> exec '!python '.shellescape('%')<CR>


" *** PLUGIN SETTINGS ***


" ** NERDTree **

" General
let NERDTreeShowLineNumbers=1

" Make it compatible with vim-template
function! GetCurrentContent()
let l:content = getline(0,line("$"))
let l:result = 0
for l:temp in l:content
if strlen(l:temp)> 0
let l:result = 1
break
endif
endfor
if l:result == 0
let l:extension = expand("%:c")

exe 'Template .' . l:extension
endif
endfunction
autocmd BufEnter * call GetCurrentContent()


" ** Syntastic **

" Recommended settings for Syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
"let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
"let g:syntastic_python_checkers = ['pylint']


" ** ctrlp.vim **
let g:ctrlp_map = '<c-p>'
let g:ctrlp_prompt_mappings = {
    \ 'AcceptSelection("e")': ['<c-t>'],
    \ 'AcceptSelection("t")': ['<cr>', '<2-LeftMouse>'],
    \ }
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 'rw'
set wildignore+=*/tmp/*,*.so,*.swp,*.zip
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']


" ** vim-template **
let g:email='dev@ekern.me'


" ** vim-airline **
set laststatus=2
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='solarized'
let g:airline_powerline_fonts = 1


" ** YouCompleteMe **
let g:ycm_server_use_vim_stdout = 0
let g:ycm_server_python_interpreter = expand('~/.pyenv/shims/python')
