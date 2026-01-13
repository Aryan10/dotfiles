
# Color definitions
readonly _CLR_RESET='\033[0m'
readonly _CLR_BOLD='\033[1m'
readonly _CLR_DIM='\033[2m'
readonly _CLR_INFO='\033[38;5;87m'      # Cyan
readonly _CLR_SUCCESS='\033[38;5;83m'   # Green
readonly _CLR_WARN='\033[38;5;221m'     # Yellow
readonly _CLR_ERROR='\033[38;5;203m'    # Red
readonly _CLR_ACCENT='\033[38;5;177m'   # Magenta

# Enable shell proxy using system settings
proxyon() {
    local host=$(gsettings get org.gnome.system.proxy.http host | tr -d \')
    local port=$(gsettings get org.gnome.system.proxy.http port)
    local user="edcguest"
    local pass="edcguest"
    
    local proxy="http://$user:$pass@$host:$port"
    export http_proxy=$proxy
    export https_proxy=$proxy

    echo -e "${_CLR_SUCCESS}${_CLR_BOLD}✓ Environment${_CLR_RESET} ${_CLR_DIM}proxy set to${_CLR_RESET} ${_CLR_INFO}$proxy${_CLR_RESET}"
    if [[ "$1" == "--local" ]]; then
        return
    fi

    echo -e "${_CLR_INFO}${_CLR_BOLD}⟳ Authenticating${_CLR_RESET} ${_CLR_DIM}to update NetworkManager and DNF...${_CLR_RESET}"
    sudo -v

    {
        echo "[connectivity]"
        echo "enabled=false"
    } | sudo tee "/etc/NetworkManager/conf.d/20-connectivity.conf" > /dev/null
    sudo systemctl restart NetworkManager

    {
        echo "[main]"
        echo "proxy=$proxy"
    } | sudo tee "/etc/dnf/dnf.conf" > /dev/null

    echo -e "${_CLR_SUCCESS}${_CLR_BOLD}✓ System proxy${_CLR_RESET} ${_CLR_DIM}configured${_CLR_RESET} ${_CLR_ACCENT}(NetworkManager, DNF)${_CLR_RESET}"
}

# Disable shell proxy
proxyoff() {
    unset http_proxy
    unset https_proxy

    # echo -e "${_CLR_SUCCESS}${_CLR_BOLD}✓ Environment${_CLR_RESET} ${_CLR_DIM}proxy disabled${_CLR_RESET}"
    if [[ "$1" == "--local" ]]; then
        return
    fi

    echo -e "${_CLR_INFO}${_CLR_BOLD}⟳ Authenticating${_CLR_RESET} ${_CLR_DIM}to restore system configuration...${_CLR_RESET}"
    sudo -v

    sudo rm -f "/etc/NetworkManager/conf.d/20-connectivity.conf"
    sudo systemctl restart NetworkManager
    
    echo "[main]" | sudo tee "/etc/dnf/dnf.conf" > /dev/null

    echo -e "${_CLR_SUCCESS}${_CLR_BOLD}✓ System proxy${_CLR_RESET} ${_CLR_DIM}removed${_CLR_RESET} ${_CLR_ACCENT}(NetworkManager, DNF)${_CLR_RESET}"
}

# Check if shell proxy is enabled
proxy() {
    if [[ -n "$http_proxy" || -n "$https_proxy" ]]; then
        echo -e "${_CLR_SUCCESS}${_CLR_BOLD}●${_CLR_RESET} ${_CLR_DIM}Proxy is${_CLR_RESET} ${_CLR_SUCCESS}${_CLR_BOLD}ENABLED${_CLR_RESET}"
        return 0
    else
        echo -e "${_CLR_ERROR}${_CLR_BOLD}●${_CLR_RESET} ${_CLR_DIM}Proxy is${_CLR_RESET} ${_CLR_ERROR}${_CLR_BOLD}DISABLED${_CLR_RESET}"
        return 1
    fi
}

# Toggle shell proxy based on system settings
proxyauto() {
    local proxy_status=$(gsettings get org.gnome.system.proxy mode)
    # echo -e "${_CLR_INFO}${_CLR_BOLD}⟳ System proxy mode:${_CLR_RESET} ${_CLR_ACCENT}${_CLR_BOLD}$proxy_status${_CLR_RESET}"

    if [[ "$proxy_status" == "'none'" ]]; then
        proxyoff --local
    else
        proxyon --local
    fi
}

# Redsocks transparent proxy redirection
proxyredsocks() {
  pkexec /usr/local/sbin/proxyredsocks "$1"
}
