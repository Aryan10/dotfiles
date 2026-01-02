# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Plugins
source "$HOME/.plugins.zsh"

# Prompt (Completion, History, Autosuggestions, Theme)
source "$HOME/.prompt.zsh"

# Custom Aliases
source "$HOME/.aliases.zsh"

# ---------------------------------------------------------
# Auto-start tmux
# ---------------------------------------------------------
if [[ -z "$TMUX" && -t 1 ]]; then
  exec tmux new-session -A -s main
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
