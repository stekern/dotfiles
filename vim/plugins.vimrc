" === ale ===
let g:ale_linters_explicit = 1
let g:ale_linters = {
\    'python': ['pylint', 'pycodestyle', 'pydocstyle'],
\    'javascript': ['eslint']
\}
let g:ale_fixers = {
\   'javascript': ['prettier']
\}
let g:ale_fix_on_save = 1
highlight ALEError ctermbg=none cterm=underline " Highlight error position with an underscore
highlight ALEWarning ctermbg=none cterm=underline " Hightlight warning position with an underscore
let g:ale_sign_error = '🚨' " Set custom error sign
let g:ale_sign_warning = '⚠' " Set custom warning sign
highlight ALEErrorSign ctermbg=18 ctermfg=red " ctermbg is set to current colour of SignColumn
highlight ALEWarningSign ctermbg=18 ctermfg=yellow" ctermbg is set to current colour of SignColum


" === fzf ===
nnoremap <silent> <leader>fb :Buffers<CR>
nnoremap <silent> <leader>fc :Commits<CR>
nnoremap <silent> <leader>ff :Files<CR>
nnoremap <silent> <leader>fbl :Lines<CR>
nnoremap <silent> <leader>fl :Ag<CR>

" Default key bindings when opening files
let g:fzf_action = {
  \ 'enter': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }
let g:fzf_layout = { 'down': '~30%' } " Default layout of the search window

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


" === vim-template ===
let g:email='dev@ekern.me'
let g:user='Erlend Ekern'

let g:templates_user_variables = [
        \   ['PYTHON_VERSION', 'GetDefaultPythonVersion'],
        \ ]

function! GetDefaultPythonVersion()
        return 3
endfunction

" === lightlight ===
let g:lightline = {
      \ 'colorscheme': g:colors_name !~ 'light' ? 'srcery_drk' : 'Tomorrow',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'fugitive#head'
      \ },
      \ }
set noshowmode " Hide duplicate mode under statusline

" === deoplete ===
let g:deoplete#enable_at_startup = 1
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>" " Cycle forwards through suggestions with <TAB>
inoremap <expr><s-tab> pumvisible() ? "\<c-p>" : "\<s-tab>" " Cycle backwards through suggestions with <SHIFT> + <TAB>
set completeopt-=preview " Disable preview window
