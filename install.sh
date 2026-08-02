#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"

  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "already linked: $dst"
    return
  fi

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    echo "backing up existing $dst -> $dst.bak"
    mv "$dst" "$dst.bak"
  fi

  ln -s "$src" "$dst"
  echo "linked $dst -> $src"
}

echo "=== Symlinking public dotfiles ==="
link "$DOTFILES_DIR/zsh/zshrc"       "$HOME/.zshrc"
link "$DOTFILES_DIR/git/gitconfig"   "$HOME/.gitconfig"
link "$DOTFILES_DIR/tmux/tmux.conf"  "$HOME/.tmux.conf"
link "$DOTFILES_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
link "$DOTFILES_DIR/karabiner"       "$HOME/.config/karabiner"
link "$DOTFILES_DIR/hammerspoon"     "$HOME/.hammerspoon"
link "$DOTFILES_DIR/nvim"            "$HOME/.config/nvim"

echo
echo "=== Cloning private dotfiles ==="
if [ -d "$DOTFILES_DIR/local/.git" ]; then
  echo "already cloned: $DOTFILES_DIR/local"
else
  git clone git@github.com:stekern/dotfiles-private.git "$DOTFILES_DIR/local" || \
    echo "skip: could not clone dotfiles-private (check SSH access)"
fi

echo
echo "=== Symlinking private doom config ==="
if [ -d "$DOTFILES_DIR/local/doom" ]; then
  link "$DOTFILES_DIR/local/doom" "$HOME/.doom.d"
else
  echo "skip: $DOTFILES_DIR/local/doom not found (is dotfiles-private cloned into local/?)"
fi

echo
read -rp "Install tinted-shell for terminal theming? [y/N] " ans
if [[ "$ans" =~ ^[yY]$ ]]; then
  if [ -d "$HOME/.config/tinted-shell" ]; then
    echo "already present: $HOME/.config/tinted-shell"
  else
    git clone https://github.com/tinted-theming/tinted-shell.git "$HOME/.config/tinted-shell"
  fi
fi

echo
read -rp "Install Doom Emacs? [y/N] " ans
if [[ "$ans" =~ ^[yY]$ ]]; then
  if [ -d "$HOME/.emacs.d" ]; then
    echo "already present: $HOME/.emacs.d"
  else
    git clone https://github.com/doomemacs/doomemacs "$HOME/.emacs.d"
    "$HOME/.emacs.d/bin/doom" install
  fi
fi

echo
echo "Done."
