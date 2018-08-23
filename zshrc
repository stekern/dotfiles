# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/home/erlend/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git vi-mode)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#

# Diable vi-mode translating shift-tab to esc. 
bindkey '^[[Z' reverse-menu-complete

alias vim="nvim"
alias egrep="egrep --color"
alias rosvm='vboxmanage startvm "ROS-Indigo" --type sdl'
alias day="base16_harmonic-light"
alias night="base16_harmonic-dark"


if [ -e ~/Documents/GitHub/Python/ntnu-gpa-calculator/gpa_fetcher.py ]; then
    alias gpa=~/Documents/GitHub/Python/ntnu-gpa-calculator/gpa_fetcher.py
fi

if [ -e ~/Documents/GitHub/Python/livingelectro-player/main.py ]; then
    alias livingelectro=~/Documents/GitHub/Python/livingelectro-player/main.py
fi

BASE16_SHELL=$HOME/.config/base16-shell/
[ -n "$PS1" ] && [ -s $BASE16_SHELL/profile_helper.sh ] && eval "$($BASE16_SHELL/profile_helper.sh)"
# Set default theme
[ ! -e  ~/.base16_theme ] && night

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm


# Add global yarn binary to PATH if it exists
if which yarn &> /dev/null; then
    export PATH="$PATH:$(yarn global bin)"
fi

# Create and go to dir
function mkcdir {
    mkdir -p -- "$1" &&
        cd -P -- "$1"
}

# Wrap tmux-template script in a function for compatibility with autocompletion
function tmux-template {
    bash ~/Documents/GitHub/Scripts/tmux-sessions/tmux-template.sh $*
}
# Set up autocomplete for tmux-template
function _tmux_template_options {
    local -a options
    options=('capra' 'easybudget')
    _describe 'values' options
}
compdef _tmux_template_options tmux-template

# Add pyenv to path
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# Add flyway to path
export PATH=$PATH:/opt/flyway/flyway-5.1.3

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change
export PATH="$PATH:$HOME/.rvm/bin"

# Do not log jrnl entries
setopt HIST_IGNORE_SPACE
alias jrnl=" jrnl"

function log_question {
   echo $1
   read
   jrnl today: ${1}. $REPLY
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='ag --hidden --ignore .cache/ --ignore node_modules/ --ignore .git -g ""'
export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND

# https://medium.com/@henriquebastos/the-definitive-guide-to-setup-my-python-workspace-628d68552e14
export WORKON_HOME=~/.ve
export PROJECT_HOME=~/pyworkspace
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
pyenv virtualenvwrapper_lazy

# Remap keys on Logitech K811 bluetooth keyboard to match Thinkpad T460 keyboard
function setup_custom_bluetooth_keyboard {
    local keyboard_id=$(xinput | egrep 'Logitech K811' | sed -r 's/^.*id=([0-9]+).*/\1/g')
    if [[ $keyboard_id =~ [0-9]+ ]]; then
        xkbcomp -i $keyboard_id ~/dotfiles/k811.xkb -synch $DISPLAY &>/dev/null && xdotool key Ctrl
    fi
}
#setup_custom_bluetooth_keyboard

# Mac keyboard shortcuts
xmodmap -e "keycode 13 = 4 dollar 4 currency dollar onequarter"
xmodmap -e "keycode 16 = 7 slash 7 slash braceleft backslash"
xmodmap -e "keycode 17 = 8 parenleft 8 8 bracketleft braceleft"
xmodmap -e "keycode 18 = 9 parenright 8 8 bracketright braceright"
