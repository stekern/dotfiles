let vim_plug_path='~/.local/share/nvim/plugged'

" Automatic vim-plug install on first launch
if empty(glob(vim_plug_path))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(vim_plug_path)

" File explorer
Plug 'tpope/vim-vinegar' " Thin wrapper for vim's netrw Version control
Plug 'tpope/vim-fugitive' " Integration with git
Plug 'idanarye/vim-merginal'
" Formatting and syntax
" Plug 'mhartington/nvim-typescript', {'do': './install.sh'} " Typescript autocompletion
" Plug 'HerringtonDarkholme/yats.vim' " Typescript syntax
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-surround'
" Plug 'w0rp/ale' " Linting, formatting and autocompletion
" Plug 'LaTeX-Box-Team/LaTeX-Box'
Plug 'editorconfig/editorconfig-vim'
" Theming
Plug 'chriskempson/base16-vim' " Base16 themes for vim
Plug 'itchyny/lightline.vim' " Lightweight statusline
" Autocomplete
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Fuzzy search
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } " System-wide fuzzy finder
Plug 'junegunn/fzf.vim'
" Wiki
Plug 'vimwiki/vimwiki'
" Writing-oriented
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'masukomi/vim-markdown-folding'
" Vim + tmux integration
Plug 'christoomey/vim-tmux-navigator'
" LaTeX plugin
" Plug 'lervag/vimtex'

call plug#end()
