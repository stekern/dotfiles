alias showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
alias hideFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'

alias disableDashboard='defaults write com.apple.dashboard mcx-disabled -boolean true; killall Dock /System/Library/CoreServices/Dock.app'
alias enableDashboard='defaults write com.apple.dashboard mcx-disabled -boolean false; killall Dock /System/Library/CoreServices/Dock.app'

alias disableMediaHotkey='launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist'
alias enableMediaHotkey='launchctl load -w /System/Library/LaunchAgents/com.apple.rcd.plist'

alias disableDesktop='defaults write com.apple.finder CreateDesktop false; killall Finder'
alias enableDesktop='defaults write com.apple.finder CreateDesktop true; killall Finder'

alias fuck='sudo $(history -p \!\!)'

alias hivedl="python3 /Volumes/Macintosh\ HD/Users/Erlend/Downloads/Python/hivedl.py"
alias karsnitt="python3 /Volumes/Macintosh\ HD/Users/Erlend/Downloads/Python/karaktersnitt.py"

alias adbtools="cd /Volumes/Macintosh\ HD/Users/Erlend/Downloads/ADT/sdk/platform-tools"
alias adb="/Volumes/Macintosh\ HD/Users/Erlend/Downloads/ADT/sdk/platform-tools/adb"
alias fastboot="/Volumes/Macintosh\ HD/Users/Erlend/Downloads/ADT/sdk/platform-tools/fastboot"

alias vim='/usr/local/bin/vim'

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
