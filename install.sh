#! /bin/bash
#
# install.sh
# Copyright (C) 2017 Erlend Ekern <dev@ekern.me>
#
# Distributed under terms of the MIT license.
#

{
    set -e
    
    # Install git
    if [ "$(which git)" == "" ]; then
        echo "[+] Installing git ..."
        sudo apt install -y git
    fi
    
    # Clone dotfiles repo
    if [ ! -d ~/dotfiles ]; then
        git clone https://github.com/stekern/dotfiles && cd dotfiles
    else
        echo "[-] Directory ~/dotfiles/ already exists! Exiting ..."
        exit 1
    fi
    
    # Install neovim and tmu
    echo "[+] Installing necessary packages from apt  ..."
    sudo add-apt-repository -y ppa:neovim-ppa/unstable
    sudo apt-get update
    sudo apt install -y neovim tmux zsh make build-essential libssl1.0-dev libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev
    
    
    # Install oh-my-zsh
    if [ ! -d ~/.oh-my-zsh ]; then
        echo "[+] Installing oh-my-zsh ..."
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sed -r 's/(^\s*)(env zsh -l)(\s*$)/\1#\2\3/g' | sed -r 's/(^\s*)(chsh -s .*)(\s*)$/\1#\2\3/g')"
        chsh -s $(which zsh)
    fi
    
    # Install nvm
    if [ ! -d ~/.nvm ]; then
        echo "[+] Installing nvm ..."
        curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
    fi
    
    # TODO: Set up pyenv, neovim-python, ...
    if [ ! -d ~/.pyenv ]; then
        echo "[+] Installing pyenv ..."
        git clone https://github.com/pyenv/pyenv.git ~/.pyenv
        echo "[+] Installing pyenv-virtualenv ..."
        git clone https://github.com/pyenv/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv
        echo "[+] Installing pyenv-virtualenvwrapper ..."
        git clone https://github.com/pyenv/pyenv-virtualenvwrapper.git ~/.pyenv/plugins/pyenv-virtualenvwrapper
    fi
    echo "[+] Installing Python 3.7.0 ..."
    ~/.pyenv/bin/pyenv install 3.7.0
    echo "[+] Installing Python 2.7.10 ..."
    ~/.pyenv/bin/pyenv install 2.7.10
    ~/.pyenv/bin/pyenv global 3.7.0
    
    echo "[+] Installing misc. Python packages ..."
    ~/.pyenv/shims/pip3.7 install --upgrade pip
    ~/.pyenv/shims/pip3.7 install virtualenv
    ~/.pyenv/shims/pip3.7 install virtualenvwrapper
    ~/.pyenv/shims/pip3.7 install neovim
    
    
    # TODO: Add custom vim-templates etc. to repo
    
    
    # Install powerline fonts
    echo "[+] Installing powerline fonts ..."
    git clone https://github.com/powerline/fonts.git --depth=1 && cd fonts && ./install.sh && cd ..  && rm -rf fonts
    
    # Install base16-shell and set theme
    if [ ! -d ~/.config/base16-shell ]; then
        echo "[+] Installing base16-shell ..."
        git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
    fi
    
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
    
        if [ -f "${symlinks[$filename]}" ]; then
            mv "${symlinks[$filename]}" "${symlinks[$filename]}.old"
        fi
    
        [ -f "$file" ] && mkdir -p "$(dirname ${symlinks[$filename]})" && ln -s "$file" "${symlinks[$filename]}"
    done
    
    env zsh -l
    
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
} &>~/log_dotfiles_installation_$(date + %s).txt
