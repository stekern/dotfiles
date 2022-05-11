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
setopt AUTO_PUSHD


# ====== Prompt ======
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
zstyle ':vcs_info:git:*' formats ' %F{242}[%b]%f'
zstyle ':vcs_info:*' enable git
PROMPT='🦄 %B%F{%(?.blue.red)}%1~%f%b$vcs_info_msg_0_%F{yellow}$(aws_vault_prompt_info)%F{default} '

aws_vault_prompt_info() {
  local symbol="🔓"
  if [ -n "${AWS_VAULT:-}" ]; then
    if [ -n "${AWS_SESSION_EXPIRATION:-}" ] && [[ "$AWS_SESSION_EXPIRATION" < "$(date -u +%FT%TZ)" ]]; then
      symbol="💀"
    fi
    echo " ($symbol $AWS_VAULT)"
  fi
}

# ====== Completion ======
# Colors for directories, ls, cd, etc.
zstyle ':completion:*' list-colors 'di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30' && export CLICOLOR=1
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
# Support bash completions
autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit
# shell completion for homebrew (https://docs.brew.sh/Shell-Completion)
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  autoload -Uz compinit
  compinit
fi

export HISTFILE=~/.zhistory # History file
export EDITOR="nvim"


# === Aliases ===
alias vim="$(brew --prefix neovim)/bin/nvim"
alias aws1="$(brew --prefix awscli@1)/bin/aws"
alias tmux="tmux -u"
alias la="ls -la"
alias ll="ls -l"
alias git-root='cd "$(git rev-parse --show-toplevel)"'
alias mkcdir='cd "$(mktemp -d)"'


# === Theming ===

# ====== base16-shell ======
BASE16_SHELL=$HOME/.config/base16-shell/
[ -n "$PS1" ] && [ -s $BASE16_SHELL/profile_helper.sh ] && eval "$($BASE16_SHELL/profile_helper.sh)"

source /opt/homebrew/opt/asdf/libexec/asdf.sh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


export PATH="$PATH:$HOME/bin"
