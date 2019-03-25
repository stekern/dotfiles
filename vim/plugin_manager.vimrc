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
Plug 'mhartington/nvim-typescript', {'do': './install.sh'} " Typescript autocompletion
Plug 'HerringtonDarkholme/yats.vim' " Typescript syntax
Plug 'tpope/vim-surround'
Plug 'w0rp/ale' " Linting, formatting and autocompletion
Plug 'LaTeX-Box-Team/LaTeX-Box'
Plug 'editorconfig/editorconfig-vim'
" Theming
Plug 'chriskempson/base16-vim' " Base16 themes for vim
Plug 'itchyny/lightline.vim' " Lightweight statusline
" Autocomplete
Plug 'neoclide/coc.nvim', {'tag': '*', 'do': { -> coc#util#install()}}
" Fuzzy search
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } " System-wide fuzzy finder
Plug 'junegunn/fzf.vim'
" Wiki
Plug 'vimwiki/vimwiki'
" LaTeX plugin
Plug 'lervag/vimtex'

call plug#end()
