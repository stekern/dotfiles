let vim_plug_path='~/.local/share/nvim/plugged'

" Automatic vim-plug install on first launch
if empty(glob(vim_plug_path))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(vim_plug_path)

Plug 'nvim-lua/plenary.nvim' " Lua library for working with neovim (required by many of the plugins below)
" File explorer
Plug 'tpope/vim-vinegar' " Thin wrapper for vim's built-in netrw explorer
" Syntax
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
" Theming
Plug 'RRethy/nvim-base16' " Base16 themes with treesitter support

" Vim + tmux integration
Plug 'christoomey/vim-tmux-navigator'
Plug 'tpope/vim-surround' " Easy to make changes to brackets, parentheses, etc.
" Git
Plug 'tpope/vim-fugitive' " Git plugin

Plug 'tpope/vim-repeat' " Enable repeat for supported plugins maps with '.'

Plug 'nvim-lua/popup.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }

" Statusline
Plug 'nvim-lualine/lualine.nvim'

" LSP
Plug 'neovim/nvim-lspconfig'
" Completion
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-path' " Completion source for local paths
Plug 'hrsh7th/cmp-buffer' " Completion source for buffer words
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
Plug 'saadparwaiz1/cmp_luasnip' " 
" Snippets
Plug 'L3MON4D3/LuaSnip' " Snippet engine

Plug 'jose-elias-alvarez/null-ls.nvim' " Useful for extending LSP functionality (e.g., for formatting)
Plug 'navarasu/onedark.nvim'

Plug 'folke/zen-mode.nvim' " Distraction-free writing

call plug#end()

set number " Enable line numbers
set relativenumber " Enable relative line numbers
set splitbelow " Focus new split
set splitright " Focus new split
set showmatch " Show matching brackets
set undofile " Enable undo file
set undodir=~/.vimundo/ " Set directory to store undo history
set incsearch " Show the next match while entering a search
set hlsearch " Enable search highlighting
set encoding=utf-8
set clipboard=unnamed
let mapleader = ' ' " Set leader to <SPACE>

syntax on


" Indentation
set expandtab " Allow tabs to be replaced by whitespace characters
set shiftwidth=2 " Number of spaces to use for automatic indentation
set tabstop=2 " Number of spaces to use when pressing <Tab>

" Enable italics
hi Comment gui=italic cterm=italic
hi htmlArg gui=italic cterm=italic

" Clear highlighting on escape in normal mode
nnoremap <esc> :noh<return><esc>

" Move display lines instead of logical
noremap <buffer> <silent> k gk
noremap <buffer> <silent> j gj
noremap <buffer> <silent> 0 g0
noremap <buffer> <silent> $ g$

" Edit vimrc
nnoremap <Leader>ve :e $MYVIMRC<CR>
" Reload vimrc
nnoremap <Leader>vr :source $MYVIMRC<CR>

" === netrw ===
let g:netrw_keepdir=0 " Current directory is always in sync

" Fix for bad styling of telescope
lua <<EOF
require('onedark').load()
EOF

" This allows us to grey out vim if inside inactive tmux pane
" (NOTE: The background in vim will be replaced with the background set in the
" shell, so the same theme should be used across)
hi Normal guibg=none
hi NonText guibg=none
hi EndOfBuffer guibg=none
hi StatusLine guibg=none
hi SignColumn guibg=none

" === vim-tmux-navigator ===
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <M-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <M-j> :TmuxNavigateDown<cr>
nnoremap <silent> <M-k> :TmuxNavigateUp<cr>
nnoremap <silent> <M-l> :TmuxNavigateRight<cr>
nnoremap <silent> <M-p> :TmuxNavigatePrevious<cr>

" We can load in lua files like this
lua <<EOF
require("config")
EOF

set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
let g:markdown_folding = 1 " Built-in markdown folding until treesitter supports it https://github.com/nvim-treesitter/nvim-treesitter/issues/2145
set foldopen-=hor " Do not open folds on horizontal movement
