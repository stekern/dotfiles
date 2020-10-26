# === General zsh config ===

# ====== Options ======
setopt NO_CASE_GLOB
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt APPEND_HISTORY
setopt HIST_VERIFY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt PROMPT_SUBST


# ====== Prompt ======
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
zstyle ':vcs_info:git:*' formats ' %F{242}[%b]%f'
zstyle ':vcs_info:*' enable git
PS1="🦄 %B%F{%(?.blue.red)}%1~%f%b\$vcs_info_msg_0_ "


# ====== Completion ======
autoload -Uz compinit && compinit
# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'
# Partial completion suggestions
zstyle ':completion:*' list-suffixes
zstyle ':completion:*' expand prefix suffix
# Completion menu
zstyle ':completion:*' menu select
bindkey '^[[Z' reverse-menu-complete
autoload -U select-word-style
select-word-style bash

export HISTFILE=~/.zhistory # History file
export EDITOR="nvim"

bindkey -v # Vi-mode


# === Aliases ===
alias vim="/usr/local/bin/nvim"
alias tmux="tmux -u"
alias la="ls -la"
alias ll="ls -l"
alias git-root='cd "$(git rev-parse --show-toplevel)"'


# === Theming ===

# ====== base16-shell ======
BASE16_SHELL=$HOME/.config/base16-shell/
[ -n "$PS1" ] && [ -s $BASE16_SHELL/profile_helper.sh ] && eval "$($BASE16_SHELL/profile_helper.sh)"


# === Miscellaneous ===
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


# === Version managers ===

# ====== nvm ======
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# ====== tfenv ======
export PATH="$HOME/.tfenv/bin:$PATH"

# ====== pyenv ======
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then eval "$(pyenv init -)"; fi
# pyenv-virtualenv
eval "$(pyenv virtualenv-init -)"
