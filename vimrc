call plug#begin('~/.local/share/nvim/plugged')

Plug 'scrooloose/nerdtree'
"Plug 'scrooloose/syntastic'
Plug 'neomake/neomake'
Plug 'aperezdc/vim-template'
Plug 'LaTeX-Box-Team/LaTeX-Box' 
Plug 'chriskempson/base16-vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'bling/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-fugitive'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

call plug#end()


" *** VIM SETTINGS ***

" Uses base16-shell to help with theme compatibility in vim
" First set 
if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
  source ~/.vimrc_background
endif

" Use shell transparency
hi! Normal ctermbg=NONE guibg=NONE
hi! NonText ctermbg=NONE guibg=NONE
highlight Normal guibg=none
highlight NonText guibg=none

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
"colorscheme base16-google-dark
"colorscheme base16-brewer
"set background=dark
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

" Change tabs using H and L
nnoremap H gT
nnoremap L gt

" Move display lines instead of logical
noremap  <buffer> <silent> k gk
noremap  <buffer> <silent> j gj
noremap  <buffer> <silent> 0 g0
noremap  <buffer> <silent> $ g$

" Indentation settings
autocmd Filetype html setlocal ts=2 sw=2 expandtab
autocmd Filetype scss setlocal ts=2 sw=2 expandtab
autocmd Filetype css setlocal ts=2 sw=2 expandtab
autocmd Filetype ruby setlocal ts=2 sw=2 expandtab
autocmd Filetype eruby setlocal ts=2 sw=2 expandtab
autocmd Filetype javascript setlocal ts=2 sw=2 expandtab

" Set default TeX flavor
let g:tex_flavor = 'latex' " .tex files are usually written in LaTeX

" *** PLUGIN SETTINGS ***


" ** NERDTree **

" General
let NERDTreeShowLineNumbers=1

" Make NERDTree compatible with vim-template
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
let g:airline_theme='base16_oceanicnext' " Matches base16-google-dark
let g:airline_powerline_fonts = 1

" ** deoplete ** 
let g:deoplete#enable_at_startup = 1
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

" ** neomake **
" Run neomake on buffer buffer write
"
function! NeomakeESlintChecker()
  let l:npm_bin = ''
  let l:eslint = 'eslint'

  if executable('npm')
    let l:npm_bin = split(system('npm bin'), '\n')[0]
  endif

  if strlen(l:npm_bin) && executable(l:npm_bin . '/eslint')
    let l:eslint = l:npm_bin . '/eslint'
  endif

  let b:neomake_javascript_eslint_exe = l:eslint
endfunction

autocmd FileType javascript :call NeomakeESlintChecker()

autocmd! BufWritePost,BufReadPost * Neomake
let g:python_host_prog='/home/erlend/.pyenv/versions/3.6.0/bin/python'
let g:neomake_open_list=0
"let g:neomake_javascript_enabled_makers = ['eslint']
"let g:neomake_jsx_enabled_makers = ['eslint']
"let g:neomake_logfile = '/home/erlend/neomake.log'
"autocmd! BufWritePost * Neomake

let g:jsx_ext_required = 0 " Allow JSX in normal JS files
