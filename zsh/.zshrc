# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Plugins
source "$HOME/.zsh-plugins.sh"

# Prompt (Completion, History, Autosuggestions, Theme)
source "$HOME/.zsh-prompt.sh"

# Shared environment
source "$HOME/.envrc"

# ---------------------------------------------------------
# Auto-start tmux
# ---------------------------------------------------------
if [[ -z "$TMUX" && $- == *i* ]]; then
    if [[ "$TERM_PROGRAM" == "vscode" ]]; then
        exec tmux new-session -A -s code
    else
        exec tmux new-session -A -s main
    fi
fi