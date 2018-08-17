#! /bin/bash
#
# install.sh
# Copyright (C) 2017 Erlend Ekern <dev@ekern.me>
#
# Distributed under terms of the MIT license.
#

err_report() {
  echo "errexit on line $(caller)" >&2
}

trap err_report ERR


if [ "$(which git)" == "" ]; then
    echo "[+] Installing git ..."
    sudo apt install -y git
fi

git clone https://github.com/stekern/dotfiles && cd dotfiles && source ./zshrc

DEFAULT_BASE16_THEME="base16-snazzy"

# Symlinking
declare -A symlinks=(
    ["./vim/vimrc"]=~/.config/nvim/init.vim
    ["gitconfig"]=~/.gitconfig
    ["tmux.conf"]=~/.tmux.conf
    ["zshrc"]=~/.zshrc
)

echo "[+] Setting up symbolic links to dotfiles ..."
for filename in "${!symlinks[@]}"; do
    file=$(realpath "$filename")
    [ -f "$file" ] && echo ln -s "$file" "${symlinks[$filename]}"
done


# Install neovim, tmux and python
echo "[+] Installing neovim and tmux ..."
sudo add-apt-repository -y ppa:neovim-ppa/unstable
sudo apt-get update
sudo apt install -y neovim tmux

# Install oh-my-zsh
echo "[+] Installing oh-my-zsh ..."
bash -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# TODO: Set up pyenv, neovim-python, ...
echo "[+] Installing pyenv ..."
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
#sudo apt install build-essential libffi-dev zlib1g-dev python-dev python-pip python3-dev python3-pip -y
sudo apt install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
xz-utils tk-dev libffi-dev liblzma-dev
pyenv install 3.7.0
pyenv install 2.7.10
pyenv global 3.7.0

pip install virtualenv
pip install virtualenvwrapper

# Symlink or alias nvim to vim
if [ -f /usr/bin/vim ]; then
    alias vim="nvim"
else
    ln -s /usr/bin/nvim /usr/bin/vim
fi


# TODO: Add custom vim-templates etc. to repo


# Install powerline fonts
echo "[+] Installing powerline fonts ..."
git clone https://github.com/powerline/fonts.git --depth=1 && cd fonts && ./install.sh && cd ..  && rm -rf fonts

# Install base16-shell and set theme
echo "[+] Installing base16-shell ..."
if [ ! -d ~/.config/base16-shell ]; then
    git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
    (source ~/.zshrc)
    ~/.config/base16-shell/scripts/$DEFAULT_BASE16_THEME.sh
fi

exit

# Install base-16-gnome-terminal
echo "[+] Installing base-16-gnome-terminal ..."
if [ ! -d ~/.config/base16-gnome-terminal ]; then
    git clone https://github.com/chriskempson/base16-gnome-terminal.git ~/.config/base16-gnome-terminal

    DFCONFDIR='/org/gnome/terminal/legacy/profiles:'
    old_profiles=($(dconf list /org/gnome/terminal/legacy/profiles:/ | egrep '^:' | sed 's/[:\/]//g'))
    (source ~/.config/base16-gnome-terminal/base16-brewer.dark.sh)
    new_profiles=($(dconf list /org/gnome/terminal/legacy/profiles:/ | egrep '^:' | sed 's/[:\/]//g'))
    added_profiles=$((${#new_profiles[@]}-${#old_profiles[@]}))

    if [ "$added_profiles" = 1 ]; then
        new_profile=$(echo "${old_profiles[@]} ${new_profiles[@]}" | tr ' ' '\n' | sort | uniq -u)
        profile_dir="$DFCONFDIR/:$new_profile"
        dconf write $DFCONFDIR/default "'$new_profile'"
        dconf write $profile_dir/background-transparency-percent "5"
        dconf write $profile_dir/use-transparent-background "true"
        dconf write $profile_dir/font "'Source Code Pro for Powerline Regular 11'"
    fi
fi
