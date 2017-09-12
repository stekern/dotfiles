let vim_plug_path='~/.local/share/nvim/plugged'

" Automatic vim-plug install on first launch
if empty(glob(vim_plug_path))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(vim_plug_path)

Plug 'scrooloose/nerdtree' " File browser
Plug 'neomake/neomake' " Linting and make framework
Plug 'chriskempson/base16-vim'
Plug 'aperezdc/vim-template' " Template library for new files
Plug 'LaTeX-Box-Team/LaTeX-Box'
Plug 'ctrlpvim/ctrlp.vim' " Fuzzy file search
Plug 'bling/vim-airline' " Statusline
Plug 'vim-airline/vim-airline-themes' " Themes for the statusline
Plug 'tpope/vim-fugitive' " Integration with git
Plug 'tpope/vim-surround' "
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' } " Async autocomplete
Plug 'wokalski/autocomplete-flow'
" For func argument completion
Plug 'Shougo/neosnippet'
Plug 'Shougo/neosnippet-snippets'

call plug#end()


" *** VIM SETTINGS ***


" General
syntax on " Enable syntax
set clipboard+=unnamedplus
set number " Enable line number
set ruler " Enable ruler
set backspace=indent,eol,start " Make backspaces better
set showmatch " Show matching brackets
set undofile " Enable undo file
set undodir=~/.vimundo/ " Set directory to store undo history
set incsearch " Show the next match while entering a search
set hlsearch " Enable search Highlighting
set autochdir
set encoding=utf-8

let mapleader = ',' " Set leader to ,

" Theming
" Use base16-shell to help with theme compatibility in vim
if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
  source ~/.vimrc_background
endif

hi Normal guibg=NONE ctermbg=NONE " Enable terminal transparency in vim (must be set after syntax!)

let g:tex_flavor = 'latex' " Set default TeX flavor
let g:jsx_ext_required = 0 " Allow JSX in normal JS files

" Indentation settings
set expandtab " Allow tabs to be replaced by whitespace characters
set shiftwidth=4 " Set default indentation
autocmd Filetype html setlocal ts=2 sw=2 expandtab
autocmd Filetype scss setlocal ts=2 sw=2 expandtab
autocmd Filetype css setlocal ts=2 sw=2 expandtab
autocmd Filetype ruby setlocal ts=2 sw=2 expandtab
autocmd Filetype eruby setlocal ts=2 sw=2 expandtab
autocmd Filetype javascript setlocal ts=2 sw=2 expandtab

" Leader commands
nmap <silent> <leader>s :lopen<CR>
nmap <silent> <leader>r :call GetDefaultRunCommand()<CR>
function! GetDefaultRunCommand()
    let l:run_commands = {
        \ 'perl': 'perl',
        \ 'python': 'python',
        \ 'tex': 'pdflatex',
        \}
    if (has_key(l:run_commands, &ft))
        execute ':term' l:run_commands[&ft] expand('%')
    endif
endfunction

" Map escape to exit terminal-mode
:tnoremap <Esc> <C-\><C-n>

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
let g:user='Erlend Ekern'

let g:templates_user_variables = [
        \   ['PYTHON_VERSION', 'GetDefaultPythonVersion'],
        \ ]

function! GetDefaultPythonVersion()
        return 3
endfunction


" ** vim-airline **
set laststatus=2 " Always display statusline
let g:airline#extensions#tabline#enabled = 1 " Enable top tabline
let g:airline_theme='base16_oceanicnext' " Matches 'brewer' theme
let g:airline_powerline_fonts = 1 " Enable powerline fonts


" ** deoplete **
let g:deoplete#enable_at_startup = 1
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"


" ** neomake **

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

" Run neomake on javascript buffer write
autocmd FileType javascript :call NeomakeESlintChecker()

autocmd! BufWritePost,BufReadPost * Neomake
"let g:python_host_prog='/home/erlend/.pyenv/versions/3.6.0/bin/python'
let g:neomake_open_list=0
"let g:neomake_javascript_enabled_makers = ['eslint']
"let g:neomake_jsx_enabled_makers = ['eslint']
"let g:neomake_logfile = '/home/erlend/neomake.log'
"autocmd! BufWritePost * Neomake

