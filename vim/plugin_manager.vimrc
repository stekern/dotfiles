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
" Formatting and syntax
Plug 'tpope/vim-surround'
Plug 'w0rp/ale' " Linting, formatting and autocompletion
Plug 'LaTeX-Box-Team/LaTeX-Box'
Plug 'editorconfig/editorconfig-vim'
" Theming
Plug 'chriskempson/base16-vim' " Base16 themes for vim
Plug 'itchyny/lightline.vim' " Lightweight statusline
" Autocomplete
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' } " Async autocomplete
Plug 'Shougo/neco-syntax' " Multiple language syntax completion for deoplete
Plug 'zchee/deoplete-jedi' " Python source for deoplete
Plug 'wokalski/autocomplete-flow' " Javascript source for deoplete
" Fuzzy search
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } " System-wide fuzzy finder
Plug 'junegunn/fzf.vim'

call plug#end()
