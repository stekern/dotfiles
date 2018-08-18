#! /bin/bash
#
# install.sh
# Copyright (C) 2017 Erlend Ekern <dev@ekern.me>
#
# Distributed under terms of the MIT license.
#

set -e
TIMESTAMP=$(date +%s)
LOG_FILE=~/log_dotfiles_installation_$TIMESTAMP.txt

# Install git
if [ "$(which git)" == "" ]; then
    echo "[+] Installing git ..."
    ( sudo apt install -y git ) &>$LOG_FILE
fi

# Clone dotfiles repo
if [ ! -d ~/dotfiles ]; then
    git clone https://github.com/stekern/dotfiles ~/dotfiles &>>$LOG_FILE
    cd ~/dotfiles
else
    echo "[-] Directory ~/dotfiles/ already exists! Exiting ..."
    exit 1
fi

# Install neovim and tmu
echo "[+] Installing necessary packages from apt  ..."
(
    sudo add-apt-repository -y ppa:neovim-ppa/unstable
    sudo apt-get update
    sudo apt install -y neovim tmux xclip zsh
    # pyenv requirements
    sudo apt install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev
) &>>$LOG_FILE



# Install oh-my-zsh
if [ ! -d ~/.oh-my-zsh ]; then
    echo "[+] Installing oh-my-zsh ..."
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sed -r 's/(^\s*)(env zsh -l)(\s*$)/\1#\2\3/g' | sed -r 's/(^\s*)(chsh -s .*)(\s*)$/\1#\2\3/g')" &>>$LOG_FILE
    chsh -s $(which zsh) 2>&1 | tee -a $LOG_FILE
fi

# Install nvm
if [ ! -d ~/.nvm ]; then
    echo "[+] Installing nvm ..."
    ( curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash ) &>>$LOG_FILE
    source ~/.nvm/nvm.sh &>>$LOG_FILE
    nvm install --lts &>>$LOG_FILE
fi

# TODO: Set up pyenv, neovim-python, ...
if [ ! -d ~/.pyenv ]; then
    echo "[+] Installing pyenv ..."
    git clone https://github.com/pyenv/pyenv.git ~/.pyenv &>>$LOG_FILE
fi

if [ ! -d ~/.pyenv/plugins/pyenv-virtualenv ]; then
    echo "[+] Installing pyenv-virtualenv ..."
    git clone https://github.com/pyenv/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv &>>$LOG_FILE
fi

if [ ! -d ~/.pyenv/plugins/pyenv-virtualenvwrapper ]; then
    echo "[+] Installing pyenv-virtualenvwrapper ..."
    git clone https://github.com/pyenv/pyenv-virtualenvwrapper.git ~/.pyenv/plugins/pyenv-virtualenvwrapper &>>$LOG_FILE
fi

has_python3=$(~/.pyenv/bin/pyenv versions | egrep '3.7.0' | wc -l)
if [ $has_python3 -eq 0 ]; then
    echo "[+] Installing Python 3.7.0 ..."
    ~/.pyenv/bin/pyenv install 3.7.0 &>>$LOG_FILE
fi

has_python2=$(~/.pyenv/bin/pyenv versions | egrep '2.7.13' | wc -l)
if [ $has_python2 -eq 0 ]; then
    echo "[+] Installing Python 2.7.13 ..."
    ~/.pyenv/bin/pyenv install 2.7.13 &>>$LOG_FILE
fi

~/.pyenv/bin/pyenv global 3.7.0 &>>$LOG_FILE

echo "[+] Installing misc. packages from pip ..."
~/.pyenv/shims/pip3.7 install --upgrade pip  &>>$LOG_FILE
~/.pyenv/shims/pip3.7 install virtualenv &>>$LOG_FILE
~/.pyenv/shims/pip3.7 install virtualenvwrapper &>>$LOG_FILE
~/.pyenv/shims/pip3.7 install neovim &>>$LOG_FILE


# TODO: Add custom vim-templates etc. to repo


# Install powerline fonts
if [ $(ls ~/.local/share/fonts | grep 'Powerline' | wc -l) -lt 50 ]; then
    echo "[+] Installing powerline fonts ..."
    ( git clone https://github.com/powerline/fonts.git --depth=1 && cd fonts && ./install.sh && cd ..  && rm -rf fonts ) &>>$LOG_FILE
fi

# Install base16-shell and set theme
if [ ! -d ~/.config/base16-shell ]; then
    echo "[+] Installing base16-shell ..."
    git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell &>>$LOG_FILE
fi

# Symlinking
declare -A symlinks=(
    ["./vim/vimrc"]=~/.config/nvim/init.vim
    ["gitconfig"]=~/.gitconfig
    ["tmux.conf"]=~/.tmux.conf
    ["zshrc"]=~/.zshrc
)

echo "[+] Setting up symbolic links ..."
for filename in "${!symlinks[@]}"; do
    (
        file=$(realpath "$filename")

        if [ -f "${symlinks[$filename]}" ]; then
            mv "${symlinks[$filename]}" "${symlinks[$filename]}.$TIMESTAMP.old"
        fi

        [ -f "$file" ] && mkdir -p "$(dirname ${symlinks[$filename]})" && ln -s "$file" "${symlinks[$filename]}"
    ) &>>$LOG_FILE
done

if [ $(which vim) == "" ]; then
    sudo ln -s /usr/bin/nvim /usr/bin/vim
fi

echo "\n------------------------------------\n"
echo "Installation of dotfiles has successfully finished!"
echo "You can view the installation log at: $LOG_FILE"
echo "\n------------------------------------\n"

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
