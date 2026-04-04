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

# Detach a long-running command into its own tmux session and block lid-sleep
# while it runs (per-command, no global setting).
det() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: det <command> [args...]"
        return 1
    fi

    if ! command -v tmux >/dev/null 2>&1; then
        echo "det: tmux not found. Install tmux to use det."
        return 1
    fi
    if ! command -v systemd-inhibit >/dev/null 2>&1; then
        echo "det: systemd-inhibit not found. Install systemd or adjust your setup."
        return 1
    fi

    local name="det_$(date +%Y%m%d_%H%M%S)"
    local cmd
    cmd=$(printf '%q ' "$@")
    cmd=${cmd% }

    tmux new-session -d -s "$name" \
        "systemd-inhibit --what=handle-lid-switch:sleep --mode=block --why='detached: $cmd' bash -lc \"$cmd\""

    echo "Started tmux session: $name"
    echo "Attach with: tmux attach -t $name"
}

# Reboot directly into Windows
winboot() {
    sudo grub2-reboot "Windows Boot Manager (on /dev/nvme0n1p1)" && reboot
}
