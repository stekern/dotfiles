##############################
#                            #
# OH-MY-ZSH CONFIG           #
#                            #
##############################

export ZSH=~/.oh-my-zsh
ZSH_THEME="robbyrussell"
HYPHEN_INSENSITIVE="true"
HIST_STAMPS="dd.mm.yyyy"
plugins=(docker git vi-mode zsh-syntax-highlighting)
setopt correct
source $ZSH/oh-my-zsh.sh
export SSH_KEY_PATH="~/.ssh/rsa_id"
export EDITOR='vim'

# Diable vi-mode translating shift-tab to esc. 
bindkey '^[[Z' reverse-menu-complete


##############################
#                            #
# ALIASES                    #
#                            #
##############################

alias vim="nvim"
# Nice dark themes: base16_google-dark, base16_materia, base16_material-darker, base16_material-vivid, base16_outrun-dark, base16_phd, base16_snazzy, base16_solarflare,
alias day="base16_atelier-forest-light"
alias night="base16_material-vivid"
alias randomtheme="ls ~/.config/base16-shell/scripts/*.sh | shuf -n 1 | xargs -i -- echo echo 'Switching to random theme: ' {}\; source {} | bash"
alias cyclefavoritethemes="while 1; do echo gruvbox-dark-pale gruvbox-dark-medium gruvbox-dark-hard google-dark materia material material-darker material-vivid outrun-dark phd snazzy solarflare | xargs -n1 | grep -v $(echo BASE16_SHELL | sed s/^base16//g) | shuf -n1 | xargs -I{} echo echo Theme: {}\; source ~/.config/base16-shell/scripts/base16-{}.sh | bash; sleep 2; done"
alias killp="bash ~/Documents/GitHub/Scripts/scripts/killp/killp.sh"
alias kssh="kitty +kitten ssh"
alias aws2="/usr/local/bin/aws"


##############################
#                            #
# CUSTOM FUNCTIONS           #
#                            #
##############################
#
function p2r {
  local input="$1"
  shift
  if [[ "$input" =~ ^http ]]; then
    docker run --rm -v "${HOME}/.rmapi:/home/user/.rmapi:rw" p2r "$input" "$@" --verbose
  else
    if [[ "$input" =~ ^.*\.pdf$ ]] && [ -e "$input" ]; then
      local file="$(basename "$input")"
      docker run --rm -v "${HOME}/.rmapi:/home/user/.rmapi:rw" -v "$input:/pdfs/$file" p2r "/pdfs/$file" "$@" --verbose
    fi
  fi
}

# Create and go to dir
function mkcdir {
    mkdir -p -- "$1" &&
        cd -P -- "$1"
}

function subdirsize {
    du -d 1 "$1" | sort -nr | while IFS= read line; do size="$(echo $line | cut -f1)"; folder="$(echo $line | cut -f2)"; gb="$(echo 'scale=4;'$size/1024^2 | bc)"; echo "$gb GB $folder"; done
}

function bash-utils {
  local util_name="$1"
  shift
  local dir="$HOME/Documents/GitHub/Scripts/scripts/bash-utils"
  local script="$dir/$util_name.sh"
  test -e "$script" && bash "$script" "$@"
}

function _bash_utils_options() {
  local options=($(find "$HOME/Documents/GitHub/Scripts/scripts/bash-utils" -name "*.sh" \
    | sed -n 's/^.*\/\(.*\)\.sh$/\1/p' \
    | sort
  ))
  _describe "values" options
}

if type compdef >/dev/null 2>/dev/null; then
    compdef _bash_utils_options bash-utils
fi


# Wrap tmux-template script in a function for compatibility with autocompletion
function tmux-template {
    bash ~/Documents/GitHub/Scripts/tmux-sessions/tmux-template.sh $*
}

# Set up autocomplete for tmux-template
function _tmux_template_options {
    local -a options
    options=("capra" "easybudget" "riot" "samf" "thesis")
    _describe "values" options
}
compdef _tmux_template_options tmux-template

# Remap keys on Logitech K811 Bluetooth keyboard to match ThinkPad T460
# Remap <Shift>4 to '$'
function configure_k811_bluetooth_keyboard {
    local k811_keyboard_id=$(xinput | egrep 'Logitech K811' | sed -r 's/^.*id=([0-9]+).*/\1/g')
    if [ "$k811_keyboard_id" ]; then
        # xdotool has to fake a button press for the changes to stick
        # Ref. https://bugs.freedesktop.org/show_bug.cgi?id=91571
        setxkbmap -device $k811_keyboard_id -print | \
            sed 's/\(xkb_keycodes.*\)"/\1+custom(k811)"/' | \
            sed 's/\(xkb_symbols.*\)"/\1+custom(mac)"/' | \
            xkbcomp -I$HOME/dotfiles/xkb -i $k811_keyboard_id -synch - $DISPLAY &>/dev/null && \
            xdotool key Ctrl || echo "Failed to set up mappings for K811 Bluetooth keyboard"
    fi
}

# Global remap of '<Shift>4' to '$'
function configure_keyboard {
    setxkbmap -print | \
        sed 's/\(xkb_symbols.*\)"/\1+custom(mac)"/' | \
        xkbcomp -I$HOME/dotfiles/xkb -synch - $DISPLAY &>/dev/null && \
        xdotool key Ctrl || echo "Failed to map '<Shift>4' to '$'"
}

# These two functions must be run in this exact order to avoid overwriting each other's settings
configure_keyboard
configure_k811_bluetooth_keyboard

# Do not log jrnl entries
setopt HIST_IGNORE_SPACE
alias jrnl=" jrnl"

function log_question {
   echo $1
   read
   jrnl today: ${1}. $REPLY
}


##############################
#                            #
# MISC.                      #
#                            #
##############################

# Configure base16-shell
BASE16_SHELL=$HOME/.config/base16-shell/
[ -n "$PS1" ] && [ -s $BASE16_SHELL/profile_helper.sh ] && eval "$($BASE16_SHELL/profile_helper.sh)"

# Set default theme for base16-shell
[ ! -e  ~/.base16_theme ] && night

# Add global yarn binary to PATH if it exists
if which yarn &> /dev/null; then
    export PATH="$PATH:$(yarn global bin)"
fi

# Configure fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='ag --hidden --ignore-dir={.cache,.git,node_modules} -g ""'
export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND


##############################
#                            #
# VERSION MANAGERS           #
#                            #
##############################

# Configure nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# Add RVM to PATH for scripting.
export PATH="$PATH:$HOME/.rvm/bin"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"

# Add pyenv to path
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# https://medium.com/@henriquebastos/the-definitive-guide-to-setup-my-python-workspace-628d68552e14
export WORKON_HOME=~/.ve
export PROJECT_HOME=~/pyworkspace
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
pyenv virtualenvwrapper_lazy

# Needs to be done after pyenv setup, as it is as python package
eval $(thefuck --alias)
