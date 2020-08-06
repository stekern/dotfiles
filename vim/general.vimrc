" General
syntax on " Enable syntax
set number " Enable line numbers
set relativenumber " Enable relative line numbers
set ruler " Enable ruler
set backspace=indent,eol,start " Make backspaces better
set showmatch " Show matching brackets
set undofile " Enable undo file
set undodir=~/.vimundo/ " Set directory to store undo history
set incsearch " Show the next match while entering a search
set hlsearch " Enable search highlighting
set encoding=utf-8
set splitright " Add new windows split to the right
set listchars=tab:»\ ,nbsp:␣,trail:·
set list " Turn on list mode to display characters set in listchars
set clipboard^=unnamed,unnamedplus
"set autochdir
" If autochdir is set, frequent 'Error detected while processing DirChanged Autocommands for *' appears when using fzf
" So lets keep it commented out for now

let mapleader = ' ' " Set leader to <SPACE>

let g:tex_flavor = 'latex' " Set default TeX flavor

" Indentation
set expandtab " Allow tabs to be replaced by whitespace characters
set shiftwidth=4 " Number of spaces to use for automatic indentation
set tabstop=4 " Number of spaces to use when pressing <Tab>

" Filetype specific
autocmd Filetype html setlocal ts=2 sw=2 expandtab
autocmd Filetype scss setlocal ts=2 sw=2 expandtab
autocmd Filetype css setlocal ts=2 sw=2 expandtab
autocmd Filetype ruby setlocal ts=2 sw=2 expandtab
autocmd Filetype eruby setlocal ts=2 sw=2 expandtab
autocmd Filetype sql setlocal ts=2 sw=2 expandtab
autocmd Filetype javascript setlocal ts=2 sw=2 expandtab
autocmd Filetype json setlocal ts=2 sw=2 expandtab
autocmd Filetype sh setlocal ts=2 sw=2 expandtab
autocmd Filetype zsh setlocal ts=2 sw=2 expandtab
autocmd Filetype yaml setlocal ts=2 sw=2 expandtab
autocmd Filetype typescript setlocal ts=2 sw=2 expandtab
autocmd Filetype vimwiki setlocal ts=2 sw=2 expandtab nofoldenable
autocmd Filetype vue setlocal ts=2 sw=2 expandtab

autocmd Filetype python setlocal foldnestmax=2 foldmethod=indent
autocmd Filetype sh setlocal ts=2 sw=2 foldnestmax=2 foldmethod=indent


autocmd BufNewFile,BufRead *.tsx set filetype=typescript

autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!

" Leader commands
nmap <silent> <leader>l :CocDiagnostics<CR>
nnoremap <silent> <leader>z :Goyo<CR>
nmap <silent> <leader>r :call GetDefaultRunCommand()<CR>
function! GetDefaultRunCommand()
    let l:run_commands = {
        \ 'perl': 'perl',
        \ 'sh': 'bash',
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

" Move display lines instead of logical
noremap  <buffer> <silent> k gk
noremap  <buffer> <silent> j gj
noremap  <buffer> <silent> 0 g0
noremap  <buffer> <silent> $ g$

" Configure vim sessions
let g:session_dir = '~/.vim-sessions'
if empty(glob(g:session_dir))
    silent exec '!mkdir' g:session_dir
endif
exec 'nnoremap <Leader>ss :mks! ' . g:session_dir . '/'
exec 'nnoremap <Leader>sr :so ' . g:session_dir. '/*.vim<C-D><BS><BS><BS><BS><BS>'

" Configure netrw
nmap <silent> <leader>e :silent Explore<CR>
let g:netrw_winsize = -30

" Enable italics
hi Comment gui=italic cterm=italic
hi htmlArg gui=italic cterm=italic

" Function for filling in templates
function! FillTemplate()
    let template_fields = {
        \ 'EMAIL': 'dev@ekern.me',
        \ 'LICENSE': 'MIT',
        \ 'NAME': 'Erlend Ekern',
        \ 'YEAR': strftime('%Y'),
        \}
    for [field, value] in items(template_fields)
        exe "silent! %s/{{" . field . "}}/" . value
    endfor
    exe "normal G"
endfunction

" Set up templates
augroup templates
    autocmd BufNewFile * silent! 0r ~/dotfiles/vim/templates/template.%:e | call FillTemplate()
augroup END
