# Color definitions
readonly _CLR_RESET='\033[0m'
readonly _CLR_BOLD='\033[1m'
readonly _CLR_DIM='\033[2m'
readonly _CLR_INFO='\033[38;5;87m'      # Cyan
readonly _CLR_SUCCESS='\033[38;5;83m'   # Green
readonly _CLR_WARN='\033[38;5;221m'     # Yellow
readonly _CLR_ERROR='\033[38;5;203m'    # Red
readonly _CLR_ACCENT='\033[38;5;177m'   # Magenta

source "$HOME/.dotfiles/proxy/proxy.zsh"

# Reboot directly into Windows
winboot() {
    sudo grub2-reboot 'Windows Boot Manager (on /dev/nvme0n1p1)' && reboot
}
