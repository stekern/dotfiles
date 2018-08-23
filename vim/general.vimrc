" General
syntax on " Enable syntax
set clipboard+=unnamedplus
set number " Enable line numbers
set relativenumber " Enable relative line numbers
set ruler " Enable ruler
"set backspace=indent,eol,start " Make backspaces better
set showmatch " Show matching brackets
set undofile " Enable undo file
set undodir=~/.vimundo/ " Set directory to store undo history
set incsearch " Show the next match while entering a search
set hlsearch " Enable search highlighting
set autochdir
set encoding=utf-8
set splitright " Add new windows split to the right

" Cycle through windows using <Tab> and <Shift-Tab>
nnoremap <Tab> <c-w>w
nnoremap <S-Tab> <c-w>W

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
if empty(glob(g:session_dir))
    silent exec '!mkdir' g:session_dir
endif
exec 'nnoremap <Leader>ss :mks! ' . g:session_dir . '/'
exec 'nnoremap <Leader>sr :so ' . g:session_dir. '/*.vim<C-D><BS><BS><BS><BS><BS>'

function ToggleLexplore()
    " Check if Lexplore has been called at some point in time
    if exists("t:netrw_lexbufnr")
        " Go to left-most window
        exec 1 "wincmd w"
        setlocal winfixwidth
        " Check if active window is netrw
        if bufname('%') =~ "NetrwTreeListing"
            let t:netrw_lexbufnr = bufnr("%")
            close
        else
            exec "topleft vertical ". (-g:netrw_winsize) . " new | buffer " t:netrw_lexbufnr
            "exec "leftabove 30vsplit | buffer " t:netrw_lexbufnr
        endif
    else
        Lexplore
    endif
endfunction

nmap <silent> <leader>e :silent Explore<CR>

let g:netrw_winsize = -30
let g:netrw_liststyle = 3 " Enable tree-style filebrowsing
