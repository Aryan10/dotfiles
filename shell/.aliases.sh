# Color definitions
readonly _CLR_RESET='\033[0m'
readonly _CLR_BOLD='\033[1m'
readonly _CLR_DIM='\033[2m'
readonly _CLR_INFO='\033[38;5;87m'      # Cyan
readonly _CLR_SUCCESS='\033[38;5;83m'   # Green
readonly _CLR_WARN='\033[38;5;221m'     # Yellow
readonly _CLR_ERROR='\033[38;5;203m'    # Red
readonly _CLR_ACCENT='\033[38;5;177m'   # Magenta

# CLI to manage proxy settings
source "$HOME/.dotfiles/proxy/proxy.sh"

# Reboot directly into Windows
winboot() {
    sudo grub2-reboot 'Windows Boot Manager (on /dev/nvme0n1p1)' && reboot
}

# Compresses files into 7z
compress-encrypt () {
    if [ "$#" -lt 2 ]; then
        echo "Usage: compress-encrypt <archive-name.7z> <files/directories...>"
        return 1
    fi

    archive="$1"
    shift

    7z a -t7z "$archive" "$@" -mhe=on -p
}

# Create a bootable url file
mkopen() {
  if [ "$#" -ne 2 ]; then
    echo "Usage: mkopen <url> <filename>"
    return 1
  fi

  local url="$1"
  local filename="$2"

  echo "<meta http-equiv=\"refresh\" content=\"0; url=${url}\">" > "${filename}.html"
}