#! /bin/bash
#
# install.sh
# Copyright (C) 2017 Erlend Ekern <dev@ekern.me>
#
# Distributed under terms of the MIT license.
#

git clone https://github.com/stekern/dotfiles && cd dotfiles

DEFAULT_BASE16_THEME="base16-snazzy"

# Symlinking
declare -A symlinks=(
    ["./vim/vimrc"]=~/.config/nvim/init.vim
    ["gitconfig"]=~/.gitconfig
    ["tmux.conf"]=~/.tmux.conf
    ["zshrc"]=~/.zshrc
)

for filename in "${!symlinks[@]}"; do
    file=$(realpath "$filename")
    echo "ln -s $file ${symlinks[$filename]}"
    # [ -f "$file" ] && echo ln -s "$file" "${symlinks[$filename]}"
done
exit

# Install oh-my-zsh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Install neovim, tmux and python
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt-get update
sudo apt install neovim
sudo apt install tmux
sudo apt install python-dev python-pip python3-dev python3-pip

# TODO: Set up pyenv, neovim-python, ...

# Symlink or alias nvim to vim
if [ -f /usr/bin/vim ]; then
    alias vim="nvim"
else
    ln -s /usr/bin/nvim /usr/bin/vim
fi


# TODO: Add custom vim-templates etc. to repo


# Install powerline fonts
git clone https://github.com/powerline/fonts.git --depth=1 && cd fonts && ./install.sh && cd ..  && rm -rf fonts

# Install base16-shell and set theme
if [ ! -d ~/.config/base16-shell ]; then
    git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
    (source ~/.zshrc)
    ~/.config/base16-shell/scripts/$DEFAULT_BASE16_THEME.sh
fi

# Install base-16-gnome-terminal
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
