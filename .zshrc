# zsh 設定

export STARSHIP_CONFIG="${HOME}/.config/starship.toml"

# 載入共用 shell 設定。
for file in "${HOME}"/.{path,exports,aliases,functions,extra}; do
    [ -r "$file" ] && source "$file"
done
unset file

# zsh 行為選項。
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt share_history
setopt inc_append_history
setopt prompt_subst

HISTFILE="${HOME}/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

# 選用 Homebrew 補完與工具整合。
if command -v brew >/dev/null 2>&1; then
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select

if command -v brew >/dev/null 2>&1 && command -v fzf >/dev/null 2>&1; then
    source "$(brew --prefix fzf 2>/dev/null)/shell/key-bindings.zsh" 2>/dev/null || true
    source "$(brew --prefix fzf 2>/dev/null)/shell/completion.zsh" 2>/dev/null || true
fi

# 目錄跳轉工具。
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# Prompt。
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
else
    PROMPT='%F{cyan}%~%f > '
fi
