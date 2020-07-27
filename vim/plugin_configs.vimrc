" === base16-vim ===
" Use base16-shell to help with theme compatibility in vim
if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
  source ~/.vimrc_background
  " Enable terminal transparency
  hi Normal guibg=NONE ctermbg=NONE " Enable terminal transparency
endif


" === ale ===
" let g:ale_completion_enabled = 1
" let g:ale_linters_explicit = 1
" let g:ale_linters = {
" \    'python': ['flake8', 'pylint'],
" \    'javascript': ['eslint', 'flow'],
" \    'typescript': ['tslint']
" \}
" let g:ale_fixers = {
" \   'css': ['prettier'],
" \   'javascript': ['eslint'],
" \   'python': ['autopep8', 'yapf'],
" \   'typescript': ['tslint', 'prettier']
" \}
" let g:ale_fix_on_save = 1
" highlight ALEError ctermbg=none cterm=underline " Highlight error position with an underscore
" highlight ALEWarning ctermbg=none cterm=underline " Hightlight warning position with an underscore
" let g:ale_sign_error = '🚨' " Set custom error sign
" let g:ale_sign_warning = '⚠' " Set custom warning sign
" highlight ALEErrorSign ctermbg=18 ctermfg=red " ctermbg is set to current colour of SignColumn
" highlight ALEWarningSign ctermbg=18 ctermfg=yellow" ctermbg is set to current colour of SignColumn
"


" === coc.nvim ===
let g:coc_status_error_sign = '🚨 ' 
let g:coc_status_warning_sign = '❕ '
highlight CocErrorSign ctermbg=18 ctermfg=red
highlight CocWarningSign ctermbg=18 ctermfg=yellow
set updatetime=300


" === fzf ===
" Search vim buffers
nnoremap <silent> <leader>fb :Buffers<CR>
" Search commits
nnoremap <silent> <leader>fc :Commits<CR>
" Search recent files
nnoremap <silent> <leader>fr :History<CR>
" Search all files in CWD
nnoremap <silent> <leader>ff :Files<CR>
" Search all lines of vim buffers
nnoremap <silent> <leader>fl :Lines<CR>
" Search all lines of files in CWD
nnoremap <silent> <leader>fg :Ag<CR>
" Search home directory
nnoremap <silent> <leader>fh :Files ~<CR>

" Default key bindings when opening files
let g:fzf_action =
\ { 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }
let g:fzf_layout = { 'down': '~40%' } " Default layout of the search window

" Customize fzf colors to match color scheme
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

" Exit fzf with <Esc>
autocmd FileType fzf tnoremap <buffer> <Esc> <c-c>

" Theme fzf statusline
function! s:fzf_statusline()
  highlight fzf1 ctermfg=red ctermbg=18
  highlight fzf2 ctermfg=red ctermbg=18
  highlight fzf3 ctermfg=red ctermbg=18
  setlocal statusline=%#fzf1#\ >\ %#fzf2#fz%#fzf3#f
endfunction
autocmd! User FzfStatusLine call <SID>fzf_statusline()


" === lightlight ===
let g:lightline = {
      \ 'colorscheme': g:colors_name !~ 'light' ? 'srcery_drk' : 'Tomorrow',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ],
      \             [ 'cocstatus' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'fugitive#head',
      \   'cocstatus': 'coc#status',
      \ },
      \ }
set noshowmode " Hide duplicate mode under statusline


" === deoplete ===
" let g:deoplete#enable_at_startup = 1
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>" " Cycle forwards through suggestions with <TAB>
inoremap <expr><s-tab> pumvisible() ? "\<c-p>" : "\<s-tab>" " Cycle backwards through suggestions with <SHIFT> + <TAB>
set completeopt-=preview " Disable preview window


" === vimwiki ===
let g:vimwiki_list = [{'path': '/media/veracrypt1/syncthing/vimwiki',
                      \ 'syntax': 'markdown', 'ext': '.md'}]
let g:vimwiki_folding = 'expr'

" === netrw ===
let g:netrw_keepdir=0 " Current directory is always in sync


" === limelight ===
let g:limelight_conceal_ctermfg = 8


" === vim-tmux-navigator ===
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <M-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <M-j> :TmuxNavigateDown<cr>
nnoremap <silent> <M-k> :TmuxNavigateUp<cr>
nnoremap <silent> <M-l> :TmuxNavigateRight<cr>
nnoremap <silent> <M-p> :TmuxNavigatePrevious<cr>
