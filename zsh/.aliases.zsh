# Color definitions (guarded for repeated sourcing)
if [[ -z "${_CLR_RESET:-}" ]]; then
    readonly _CLR_RESET='\033[0m'
    readonly _CLR_BOLD='\033[1m'
    readonly _CLR_DIM='\033[2m'
    readonly _CLR_INFO='\033[38;5;87m'      # Cyan
    readonly _CLR_SUCCESS='\033[38;5;83m'   # Green
    readonly _CLR_WARN='\033[38;5;221m'     # Yellow
    readonly _CLR_ERROR='\033[38;5;203m'    # Red
    readonly _CLR_ACCENT='\033[38;5;177m'   # Magenta
fi

source "$HOME/.dotfiles/proxy/proxy.zsh"

# Detach a long-running command into its own tmux session.
det() {
    "$HOME/.dotfiles/bin/det" "$@"
}

# Reboot directly into Windows
winboot() {
    sudo grub2-reboot "Windows Boot Manager (on /dev/nvme0n1p1)" && reboot
}
