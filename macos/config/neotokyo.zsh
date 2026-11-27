# NeoTokyo for native macOS Zsh. Load at the end of .zshrc.
[[ -o interactive ]] || return
[[ -n ${NEOTOKYO_LOADED:-} ]] && return
typeset -g NEOTOKYO_LOADED=1
typeset -g NEOTOKYO_HOME="${${(%):-%N}:A:h}"
typeset -g NEOTOKYO_BREW_PREFIX=${NEOTOKYO_BREW_PREFIX:-}

# Keep the user's command and completion paths, including corporate tools.
typeset -U path fpath
if [[ -x /opt/homebrew/bin/brew ]]; then
    typeset -g NEOTOKYO_BREW_PREFIX=/opt/homebrew
elif [[ -x /usr/local/bin/brew ]]; then
    typeset -g NEOTOKYO_BREW_PREFIX=/usr/local
elif (( $+commands[brew] )); then
    typeset -g NEOTOKYO_BREW_PREFIX="$(brew --prefix)"
fi
if [[ -n ${NEOTOKYO_BREW_PREFIX:-} ]]; then
    path=("$NEOTOKYO_BREW_PREFIX/bin" "$NEOTOKYO_BREW_PREFIX/sbin" $path)
    fpath=("$NEOTOKYO_BREW_PREFIX/share/zsh/site-functions" "$NEOTOKYO_BREW_PREFIX/share/zsh-completions" $fpath)
fi

HISTFILE=${HISTFILE:-${ZDOTDIR:-$HOME}/.zsh_history}
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE HIST_REDUCE_BLANKS HIST_SAVE_NO_DUPS HIST_FCNTL_LOCK
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS INTERACTIVE_COMMENTS
unsetopt BEEP INC_APPEND_HISTORY INC_APPEND_HISTORY_TIME

autoload -Uz compinit
# compinit retains its ownership/permissions checks.
if (( ! $+functions[compdef] )); then compinit; fi
zmodload zsh/complist
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{#BD93F9}%d%f'
zstyle ':completion:*' list-colors 'di=38;2;91;140;255' 'ex=38;2;90;247;142' 'ln=38;2;139;233;253'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' rehash true

bindkey -e
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[OA' up-line-or-beginning-search
bindkey '^[OB' down-line-or-beginning-search
bindkey '^R' history-incremental-search-backward
bindkey '^L' clear-screen
bindkey '^Z' undo
bindkey '^[z' redo
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[b' backward-word
bindkey '^[f' forward-word
bindkey '^[[3~' delete-char
bindkey '^[[3;5~' kill-word
bindkey '^[[127;5u' backward-kill-word
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line
bindkey '^[[Z' reverse-menu-complete
_neotokyo_newline() { LBUFFER+=$'\n'; }
zle -N _neotokyo_newline
bindkey '^[[13;2u' _neotokyo_newline

typeset -g ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6B7089'
typeset -ga ZSH_AUTOSUGGEST_STRATEGY=(history completion)
typeset -ga ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(forward-char end-of-line vi-forward-char vi-end-of-line vi-add-eol)
typeset -ga ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=(forward-word)
if [[ -r "$NEOTOKYO_BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$NEOTOKYO_BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

export EZA_CONFIG_DIR="$NEOTOKYO_HOME/eza"
export BAT_THEME=Dracula
export LESS='-R'
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:-} --height=45% --layout=reverse --border=rounded --color=bg:#0B1020,bg+:#20153D,fg:#8BE9FD,fg+:#FFFFFF,hl:#FF79C6,hl+:#FF79C6,prompt:#00F5D4,pointer:#FF79C6,marker:#5AF78E,header:#BD93F9,border:#5B8CFF,info:#6B7089"
export FZF_CTRL_T_OPTS="${FZF_CTRL_T_OPTS:-} --preview 'bat --color=always --style=numbers --line-range=:200 -- {}'"
export FZF_ALT_C_OPTS="${FZF_ALT_C_OPTS:-} --preview 'eza --tree --level=2 --color=always --icons=always -- {}'"
if (( $+commands[fzf] )); then
    source <(fzf --zsh)
fi
if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh)"
fi

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias docs='cd ~/Documents'
alias downloads='cd ~/Downloads'
alias desktop='cd ~/Desktop'
alias repos='cd ~/repos'
alias gs='git status'
alias ga='git add .'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate --all'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'
alias gpull='git pull'
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kdp='kubectl describe pod'
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
if (( $+commands[eza] )); then
    alias ls='eza --icons=auto --group-directories-first'
    alias ll='eza --long --all --header --git --icons=auto --group-directories-first'
    alias la='eza --all --icons=auto --group-directories-first'
    alias lt='eza --tree --level=2 --icons=auto --group-directories-first'
else
    alias ll='ls -lah'
fi
if (( $+commands[bat] )); then alias catc='bat --paging=never'; fi
alias hist='fc -l -50'
alias histall='fc -l 1'
alias edit-profile='${EDITOR:-nano} "$NEOTOKYO_HOME/local.zsh"'
alias reload='exec /bin/zsh -l'
mkcd() { [[ $# -eq 1 ]] || { print -u2 'Uso: mkcd carpeta'; return 2; }; mkdir -p -- "$1" && cd -- "$1"; }
pwdc() { print -rn -- "$PWD" | pbcopy; }
ex() { open "${1:-.}"; }
ff() {
    [[ $# -eq 1 ]] || { print -u2 'Uso: ff texto'; return 2; }
    command rg --files --hidden -g '!.git' | command rg --fixed-strings --ignore-case -- "$1"
}
sysinfo() { sw_vers; uname -m; sysctl -n hw.memsize | awk '{ printf "RAM: %.0f GB\n", $1 / 1073741824 }'; }
neotokyo-help() { cat "$NEOTOKYO_HOME/shortcuts.txt"; }
neotokyo-doctor() {
    local tool missing=0
    print -r -- "NeoTokyo · Zsh $ZSH_VERSION · $(uname -m)"
    for tool in oh-my-posh fzf zoxide eza bat rg; do
        if (( $+commands[$tool] )); then print -r -- "OK  $tool: $commands[$tool]"; else print -r -- "FALTA  $tool"; missing=1; fi
    done
    for tool in zsh-autosuggestions zsh-syntax-highlighting; do
        [[ -r "$NEOTOKYO_BREW_PREFIX/share/$tool/$tool.zsh" ]] && print -r -- "OK  $tool" || { print -r -- "FALTA  $tool"; missing=1; }
    done
    print -r -- "Historial: $HISTFILE · límite: $SAVEHIST"
    print 'Fuente esperada en iTerm2: Monofoki Nerd Font, 14 pt.'
    return $missing
}

if (( $+commands[oh-my-posh] )); then
    eval "$(oh-my-posh init zsh --config "$NEOTOKYO_HOME/neotokyo.omp.json")"
else
    PROMPT='%F{#62D6C8}%n %F{#5B8CFF}%~%f'$'\n''%F{#FF79C6}# %f'
fi

# User overrides survive reinstallations; load before the highlighting plugin.
[[ -r "$NEOTOKYO_HOME/local.zsh" ]] && source "$NEOTOKYO_HOME/local.zsh"
if [[ -r "$NEOTOKYO_BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$NEOTOKYO_BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
    ZSH_HIGHLIGHT_STYLES[default]='fg=#8BE9FD'
    ZSH_HIGHLIGHT_STYLES[command]='fg=#FF79C6'
    ZSH_HIGHLIGHT_STYLES[builtin]='fg=#FF79C6'
    ZSH_HIGHLIGHT_STYLES[function]='fg=#FF79C6'
    ZSH_HIGHLIGHT_STYLES[alias]='fg=#FF79C6'
    ZSH_HIGHLIGHT_STYLES[precommand]='fg=#8BE9FD'
    ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#8BE9FD'
    ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#FF79C6'
    ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#00F5D4'
    ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#00F5D4'
    ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#5B8CFF'
    ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#5B8CFF'
    ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#9D4EDD'
    ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=#9D4EDD'
    ZSH_HIGHLIGHT_STYLES[comment]='fg=#6A9955'
    ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#FF5F87,underline'
    ZSH_HIGHLIGHT_STYLES[path]='fg=#5B8CFF,underline'
fi
