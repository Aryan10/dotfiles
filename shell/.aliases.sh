# Color definitions
_CLR_RESET='\033[0m'
_CLR_BOLD='\033[1m'
_CLR_DIM='\033[2m'
_CLR_INFO='\033[38;5;87m'      # Cyan
_CLR_SUCCESS='\033[38;5;83m'   # Green
_CLR_WARN='\033[38;5;221m'     # Yellow
_CLR_ERROR='\033[38;5;203m'    # Red
_CLR_ACCENT='\033[38;5;177m'   # Magenta

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

# Mount Google Drive (My Drive + Shared with me)
gmount() {
    local BASE="$HOME/gdrive"
    local ALT="$HOME/gdrive-u"
    local SHARED="$HOME/gdrive-shared"

    mkdir -p "$BASE"
    echo "[*] Mounting gdrive (My Drive) at $BASE"
    rclone mount gdrive: "$BASE" \
        --vfs-cache-mode full \
        --vfs-cache-max-size 10G \
        --buffer-size 256M \
        --daemon

   mkdir -p "$ALT"
   echo "[*] Mounting gdrive-u (My Drive) at $ALT"
   rclone mount gdrive-u: "$ALT" \
       --vfs-cache-mode full \
       --vfs-cache-max-size 10G \
       --buffer-size 256M \
       --daemon

	# Optional shared mount
    if [[ "$1" == "--shared" ]]; then
        mkdir -p "$SHARED"
        echo "[*] Mounting gdrive (Shared with me) at $SHARED"
        rclone mount gdrive: "$SHARED" \
            --drive-shared-with-me \
            --vfs-cache-mode full \
            --vfs-cache-max-size 10G \
            --buffer-size 256M \
            --daemon
    fi

    echo "[✓] Mounts started"
}

# C++ extreme compilation for debugging
cpp() {
	# fast = -std=c++23 -O0 -g1
	# best = -std=c++23 -Og -g3 -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC -fsanitize=address,undefined,leak -fno-sanitize-recover=all -fstack-protector-strong -fno-omit-frame-pointer

    g++ -std=c++23 -Og -g3 \
    -Wall -Wextra -Wpedantic \
    -Wshadow -Wconversion -Wsign-conversion \
    -Wfloat-equal -Wduplicated-cond -Wlogical-op \
    -Wuseless-cast -Wformat=2 -Wnull-dereference \
    -Wdouble-promotion -Wimplicit-fallthrough \
    -Wcast-align -Wstrict-overflow=5 \
    -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC \
    -fsanitize=address,undefined,leak \
    -fno-sanitize-recover=all \
    -fstack-protector-strong \
    -fno-omit-frame-pointer \
    -o out "$1" && \
    ./out < input.txt
    rm out
}

alias c++=cpp
