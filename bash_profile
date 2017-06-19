alias vim='/usr/local/bin/nvim'

# Disable duplicate commands in terminal history
export HISTCONTROL=ignoreboth:erasedups

# Setting PATH for Python 3.4
# The orginal version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.4/bin:${PATH}"
export PATH

export PATH=${PATH}:/usr/local/mysql/bin/
export PATH="/usr/local/bin:$PATH"
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

source ~/.profile

# Enable shell integration in iTerm 2
source ~/.iterm2_shell_integration.`basename $SHELL`

# Settings for pyenv
export PYENV_ROOT=/usr/local/var/pyenv
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

# Enable git completion in command line
test -f ~/.git-completion.bash && . $_
