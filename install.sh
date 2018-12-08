#! /bin/bash
#
# install.sh
# Copyright (C) 2017 Erlend Ekern <dev@ekern.me>
#
# Distributed under terms of the MIT license.
#

set -e
trap ERR
TIMESTAMP=$(date +%s)
LOG_FILE=~/log_stekern_dotfiles_$TIMESTAMP.txt

function confirm {
  while true; do
    read -p "$1" yn
    case $yn in
      [yY]* ) return 0;;
      [nN]* ) return 1;;
      * ) echo "Please answer yes or no.";;
    esac
  done
}

function symlink {
  file=$(realpath "$1") &>>$LOG_FILE

  if [ -f "$2" ]; then
    if confirm "File '$2' already exists. Rename it to '$2.$TIMESTAMP.old'? "; then
      mv "$2" "$2.$TIMESTAMP.old" &>>$LOG_FILE
    else
      return 0
    fi
  fi

  [ -f "$file" ] && mkdir -p "$(dirname $2)" && sudo ln -s "$file" "$2" &>>$LOG_FILE
}

# Clone dotfiles repo
if [ ! -d ~/dotfiles ]; then
  # Install git
  if [ "$(which git)" == "" ]; then
    echo "[+] Installing git ..."
    sudo apt install -y git &>>$LOG_FILE
  fi
  git clone https://github.com/stekern/dotfiles ~/dotfiles &>>$LOG_FILE
  cd ~/dotfiles
else
  echo "[-] Directory ~/dotfiles/ already exists! Exiting ..."
  exit 1
fi

#####################################################
#                                                   #
# MISC. INSTALLATION CONFIGURATION                  #
#                                                   #
#####################################################

# Set up automatic installation of a required package
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections

#####################################################
#                                                   #
# MAIN INSTALLATION PHASE                           #
#                                                   #
#####################################################

if confirm "Would you like to install albert, Spotify and misc. media packages? "; then
  echo "[+] Installing albert, Spotify and misc. media packages ..."
  {
    # Add signing keys for albert repository
    wget -nv -O Release.key https://build.opensuse.org/projects/home:manuelschneid3r/public_key
    sudo apt-key add - < Release.key && rm Release.key
    # Add repository for albert
    sudo sh -c "echo 'deb http://download.opensuse.org/repositories/home:/manuelschneid3r/xUbuntu_18.04/ /' > /etc/apt/sources.list.d/home:manuelschneid3r.list"
    # Add signing keys for Spotify repository
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90
    # Add repository for Spotify
    echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt update
    sudo apt install -y albert spotify-client ubuntu-restricted-extras
    # Install necessary libraries for Spotify local files
    sudo wget -N https://github.com/ramedeiros/spotify_libraries/raw/master/libavcodec.so.54.71.100 -O /usr/lib/x86_64-linux-gnu/libavcodec.so.54 && sudo wget -N https://github.com/ramedeiros/spotify_libraries/raw/master/libavformat.so.54.36.100 -O /usr/lib/x86_64-linux-gnu/libavformat.so.54 && sudo wget -N https://github.com/ramedeiros/spotify_libraries/raw/master/libavutil.so.52.6.100 -O /usr/lib/x86_64-linux-gnu/libavutil.so.52 && sudo ldconfig
  } &>>$LOG_FILE
fi

if confirm "Would you like to install htop, tldr and tlp? "; then
  echo "[+] Installing htop, tldr and tlp ..."
  sudo apt install -y htop tldr tlp &>>$LOG_FILE
fi

if confirm "Would you like to configure misc. ThinkPad T460 tweaks? "; then
  echo "[+] Configuring misc. ThinkPad T460 tweaks ..."
  {
    # xdotool is needed for keyboard configuration
    # gnome-sushi is needed for file/folder previews in nautilus
    # p7zip-full is needed to extract password-protected .zip-files
    sudo apt install -y xdotool gnome-sushi p7zip-full

    # Misc. modules for tlp
    sudo apt install -y tlp-rdw acpi-call-dkms

    # Only show apps in the current workspace when using <Alt><Tab>
    gsettings set org.gnome.shell.app-switcher current-workspace-only "true"

    # Map <Ctrl>+Volume keys to media prev, play, next
    gsettings set org.gnome.settings-daemon.plugins.media-keys play "<Primary>AudioLowerVolume"
    gsettings set org.gnome.settings-daemon.plugins.media-keys previous "<Primary>AudioMute"
    gsettings set org.gnome.settings-daemon.plugins.media-keys next "<Primary>AudioRaiseVolume"

    # Swap <CapsLock> and <Esc>
    gsettings set org.gnome.desktop.input-sources xkb-options "['caps:swapescape']"

    # Disable <Print>
    gsettings set org.gnome.settings-daemon.plugins.media-keys screenshot ''

    # Disable overview when pressing <Super>
    gsettings set org.gnome.mutter overlay-key ''

    # Cycle through application windows using <Alt>bar
    gsettings set org.gnome.desktop.wm.keybindings switch-group "['<Alt>bar']"
    gsettings set org.gnome.desktop.wm.keybindings switch-group-backward "['<Shift><Alt>bar']"

    # Disable desktop icons
    gsettings set org.gnome.desktop.background show-desktop-icons "false"

    # Configure nautilus
    gsettings set org.gnome.nautilus.list-view default-zoom-level "small"
    gsettings set org.gnome.nautilus.list-view use-tree-view "true"
    gsettings set org.gnome.nautilus.preferences default-folder-viewer "list-view"

    # Set workspace labels
    # gsettings set org.gnome.desktop.wm.preferences workspace-names "['Misc.', 'Thesis', 'Development', 'Coursework']"

    # Enable natural scrolling for mouse
    gsettings set org.gnome.desktop.peripherals.mouse natural-scroll "true"

    # Disable Gnome overwriting custom xkb keyboard configurations
    gsettings set org.gnome.settings-daemon.plugins.keyboard active "false"

    # symlink "./thinkpad/10-trackpoint.rules" "/etc/udev/rules.d/10-trackpoint.rules"
    # xinput --set-prop "TPPS/2 IBM TrackPoint" "libinput Natural Scrolling Enabled" 1
    # xinput --set-prop "TPPS/2 IBM TrackPoint" "libinput Accel Speed" "-0.40"
  } &>>$LOG_FILE
fi

# Install neovim, tmux and zsh
echo "[+] Installing neovim (+silversearcher-ag), tmux (+xclip) and zsh ..."
{
  sudo add-apt-repository -y ppa:neovim-ppa/unstable
  sudo apt update
  sudo apt install -y neovim tmux zsh
  # Additional installations for neovim and tmux
  sudo apt install -y xclip silversearcher-ag
} &>>$LOG_FILE


# Install oh-my-zsh
if [ ! -d ~/.oh-my-zsh ]; then
  echo "[+] Installing oh-my-zsh ..."
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sed -r 's/(^\s*)(env zsh -l)(\s*$)/\1#\2\3/g' | sed -r 's/(^\s*)(chsh -s .*)(\s*)$/\1#\2\3/g')" &>>$LOG_FILE
  chsh -s $(which zsh) 2>&1 | tee -a $LOG_FILE
fi

# Install nvm
if [ ! -d ~/.nvm ]; then
  echo "[+] Installing nvm ..."
  {
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
    source ~/.nvm/nvm.sh
  } &>>$LOG_FILE
  echo "[+] Installing latest LTS version of Node.js ..."
  nvm install --lts &>>$LOG_FILE
fi

if [ ! -d ~/.pyenv ]; then
  # Install dependencies for pyenv
  echo "[+] Installing dependencies for pyenv ..."
  sudo apt install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
  libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
  xz-utils tk-dev libffi-dev liblzma-dev &>>$LOG_FILE

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
{
  ~/.pyenv/shims/pip3.7 install --upgrade pip
  ~/.pyenv/shims/pip3.7 install virtualenv
  ~/.pyenv/shims/pip3.7 install virtualenvwrapper
  ~/.pyenv/shims/pip3.7 install neovim
} &>>$LOG_FILE

# Install powerline fonts
if [ $(ls ~/.local/share/fonts | grep 'Powerline' | wc -l) -lt 50 ]; then
  echo "[+] Installing powerline fonts ..."
  {
    git clone https://github.com/powerline/fonts.git --depth=1
    cd fonts && ./install.sh
    cd ..  && rm -rf fonts
  } &>>$LOG_FILE
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
  symlink "$filename" "${symlinks[$filename]}"
done

if [ "$(which vim)" == "" ]; then
  sudo ln -s /usr/bin/nvim /usr/bin/vim &>>$LOG_FILE
fi

# Configure GNOME terminal
echo "[+] Configuring GNOME terminal ..."
{
  default_profile=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'" )
  gsettings_schema="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$default_profile/"
  gsettings set $gsettings_schema scrollbar-policy "never"
  gsettings set $gsettings_schema use-theme-transparency "false"
  gsettings set $gsettings_schema use-transparent-background "true"
  gsettings set $gsettings_schema background-transparency-percent "3"
  gsettings set $gsettings_schema font "Source Code Pro for Powerline Regular 11"
} &>>$LOG_FILE

echo ""
echo "------------------------------------"
echo "Installation of dotfiles has successfully finished!"
echo "You can view the installation log at: $LOG_FILE"
echo "------------------------------------"
echo ""

env zsh -l
