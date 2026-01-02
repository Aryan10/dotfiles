# ---------------------------------------------------------
# Plugins
# ---------------------------------------------------------

# --- Zoxide ---
eval "$(zoxide init zsh)"
alias cd="z"

# --- Eza ---
alias ls="eza --icons --group-directories-first"
alias la="eza -lah --icons --group-directories-first"
alias lt="eza -T --icons --level=3"

# --- Batman ---
export MANPAGER="sh -c 'col -bx | bat --paging=always --language=man'"
export MANROFFOPT="-c"
export LESS='-R --mouse'  # Fix scrollwheel in less/man/bat

# ----- Fish-style up/down arrow search -----
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# --- Syntax highlighting (must be last plugin) ---
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/usr/share/zsh-syntax-highlighting/highlighters