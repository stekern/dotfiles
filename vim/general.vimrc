" General
syntax on " Enable syntax
set clipboard+=unnamedplus
set number " Enable line numbers
set relativenumber " Enable relative line numbers
set ruler " Enable ruler
set backspace=indent,eol,start " Make backspaces better
set showmatch " Show matching brackets
set undofile " Enable undo file
set undodir=~/.vimundo/ " Set directory to store undo history
set incsearch " Show the next match while entering a search
set hlsearch " Enable search highlighting
set autochdir
set encoding=utf-8

let mapleader = ' ' " Set leader to <SPACE>

" Theming
" Use base16-shell to help with theme compatibility in vim
if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
  source ~/.vimrc_background
endif

" Enable terminal transparency in vim (must be set after syntax!)
hi Normal guibg=NONE ctermbg=NONE

let g:tex_flavor = 'latex' " Set default TeX flavor

" Indentation
set expandtab " Allow tabs to be replaced by whitespace characters
set shiftwidth=4 " Set default indentation
autocmd Filetype html setlocal ts=2 sw=2 expandtab
autocmd Filetype scss setlocal ts=2 sw=2 expandtab
autocmd Filetype css setlocal ts=2 sw=2 expandtab
autocmd Filetype ruby setlocal ts=2 sw=2 expandtab
autocmd Filetype eruby setlocal ts=2 sw=2 expandtab
autocmd Filetype sql setlocal ts=2 sw=2 expandtab
autocmd Filetype javascript setlocal ts=2 sw=2 expandtab
autocmd Filetype json setlocal ts=2 sw=2 expandtab


" Leader commands
nmap <silent> <leader>l :lopen<CR>
nmap <silent> <leader>r :call GetDefaultRunCommand()<CR>
function! GetDefaultRunCommand()
    let l:run_commands = {
        \ 'perl': 'perl',
        \ 'python': 'python',
        \ 'tex': 'pdflatex',
        \}
    if (has_key(l:run_commands, &ft))
        execute ':-tabnew | term' l:run_commands[&ft] expand('%')
    endif
endfunction

" Map escape to exit terminal-mode
tnoremap <Esc> <C-\><C-n>

" Clear highlighting on escape in normal mode
nnoremap <esc> :noh<return><esc>

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

let g:session_dir = '~/.vim-sessions'
exec 'nnoremap <Leader>ss :mks! ' . g:session_dir . '/'
exec 'nnoremap <Leader>sr :so ' . g:session_dir. '/*.vim<C-D><BS><BS><BS><BS><BS>'

function! SessionName()
  call inputsave()
  let name = input('Save session as: ')
  echo name
  call inputrestore()
endfunction
