# Main proxy command dispatcher
proxy() {
    local command="${1:-help}"
    
    case "$command" in
        shell)
            _proxy_shell "$2" "$3"
            ;;
        system)
            _proxy_system "$2" "$3"
            ;;
        redsocks)
            shift
            _proxy_redsocks "$@"
            ;;
        help)
            _proxy_help
            ;;
        *)
            _proxy_help
            ;;
    esac
}

# Shell proxy management
_proxy_shell() {
    local subcommand="$1"
    
    case "$subcommand" in
        enable)
            _proxyon
            ;;
        disable)
            _proxyoff
            ;;
        configure)
            _proxyauto
            ;;
        status)
            _proxy_status
            ;;
        *)
            echo -e "${_CLR_ERROR}Unknown shell subcommand: $subcommand${_CLR_RESET}"
            echo "Usage: proxy shell {enable|disable|configure|status}"
            return 1
            ;;
    esac
}

# System proxy management
_proxy_system() {
    local subcommand="$1"
    local value="$2"
    
    case "$subcommand" in
        set)
            if [[ -z "$value" ]]; then
                echo -e "${_CLR_ERROR}Usage: proxy system set <IP_SUFFIX>${_CLR_RESET}"
                echo "Example: proxy system set 172 (sets 172.31.x.x)"
                return 1
            fi
            _proxy_system_set "$value"
            ;;
        enable)
            _proxy_system_enable
            ;;
        disable)
            _proxy_system_disable
            ;;
        *)
            echo -e "${_CLR_ERROR}Unknown system subcommand: $subcommand${_CLR_RESET}"
            echo "Usage: proxy system {set <IP>|enable|disable}"
            return 1
            ;;
    esac
}

# Set system proxy with auto-prefixing
_proxy_system_set() {
    local raw="$1"
    local ip dots

    dots=$(grep -o '\.' <<< "$raw" | wc -l)
    case "$dots" in
        3)
            ip="$raw"
            ;;
        2)
            [[ "$raw" == .* ]] || { echo "Invalid IP: $raw"; return 1; }
            ip="172.31${raw}"
            ;;
        1)  
            ip="172.31.$raw"
            ;;
        *)
            echo "Invalid IP format: $raw"
            return 1
            ;;
    esac
    
    echo -e "${_CLR_INFO}${_CLR_BOLD}⟳ Setting system proxy${_CLR_RESET} ${_CLR_DIM}to${_CLR_RESET} ${_CLR_ACCENT}$ip${_CLR_RESET}"
    sudo -v
    
    gsettings set org.gnome.system.proxy.http host "$ip"
    gsettings set org.gnome.system.proxy.https host "$ip"

    echo -e "${_CLR_SUCCESS}${_CLR_BOLD}✓ System proxy${_CLR_RESET} ${_CLR_DIM}configured${_CLR_RESET}"
}

# Set system proxy mode to manual
_proxy_system_enable() {
    echo -e "${_CLR_INFO}${_CLR_BOLD}⟳ Enabling system proxy${_CLR_RESET}"
    gsettings set org.gnome.system.proxy mode manual
    echo -e "${_CLR_SUCCESS}${_CLR_BOLD}✓ System proxy${_CLR_RESET} ${_CLR_DIM}enabled${_CLR_RESET}"
}

# Set system proxy mode to none
_proxy_system_disable() {
    echo -e "${_CLR_INFO}${_CLR_BOLD}⟳ Disabling system proxy${_CLR_RESET}"
    gsettings set org.gnome.system.proxy mode none
    echo -e "${_CLR_SUCCESS}${_CLR_BOLD}✓ System proxy${_CLR_RESET} ${_CLR_DIM}disabled${_CLR_RESET}"
}

# Enable shell proxy using system settings
_proxyon() {
    local host=$(gsettings get org.gnome.system.proxy.http host | tr -d \')
    local port=$(gsettings get org.gnome.system.proxy.http port)
    local user="edcguest"
    local pass="edcguest"
    
    local proxy="http://$user:$pass@$host:$port"
    export http_proxy=$proxy
    export https_proxy=$proxy
    export HTTP_PROXY=$proxy
    export HTTPS_PROXY=$proxy

    echo -e "${_CLR_SUCCESS}${_CLR_BOLD}✓ Environment${_CLR_RESET} ${_CLR_DIM}proxy set to${_CLR_RESET} ${_CLR_INFO}$proxy${_CLR_RESET}"

    if [[ "$1" == "--local" ]]; then
        return
    fi

    echo -e "${_CLR_INFO}${_CLR_BOLD}⟳ Authenticating${_CLR_RESET} ${_CLR_DIM}to update NetworkManager/conf.d and dnf/dnf.conf...${_CLR_RESET}"
    sudo -v || return 1

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
_proxyoff() {
    unset http_proxy
    unset https_proxy
    unset HTTP_PROXY
    unset HTTPS_PROXY

    if [[ "$1" == "--local" ]]; then
        return
    fi

    echo -e "${_CLR_INFO}${_CLR_BOLD}⟳ Authenticating${_CLR_RESET} ${_CLR_DIM}to restore system configuration...${_CLR_RESET}"
    sudo -v || return 1

    sudo rm -f "/etc/NetworkManager/conf.d/20-connectivity.conf"
    sudo systemctl restart NetworkManager
    
    echo "[main]" | sudo tee "/etc/dnf/dnf.conf" > /dev/null

    echo -e "${_CLR_SUCCESS}${_CLR_BOLD}✓ System proxy${_CLR_RESET} ${_CLR_DIM}removed${_CLR_RESET} ${_CLR_ACCENT}(NetworkManager, DNF)${_CLR_RESET}"
}

# Check if shell proxy is enabled
_proxy_status() {
    if [[ -n "$http_proxy" || -n "$https_proxy" ]]; then
        echo -e "${_CLR_SUCCESS}${_CLR_BOLD}●${_CLR_RESET} ${_CLR_DIM}Proxy is${_CLR_RESET} ${_CLR_SUCCESS}${_CLR_BOLD}ENABLED${_CLR_RESET}"
        return 0
    else
        echo -e "${_CLR_ERROR}${_CLR_BOLD}●${_CLR_RESET} ${_CLR_DIM}Proxy is${_CLR_RESET} ${_CLR_ERROR}${_CLR_BOLD}DISABLED${_CLR_RESET}"
        return 1
    fi
}

# Toggle shell proxy based on system settings
_proxyauto() {
    local proxy_status=$(gsettings get org.gnome.system.proxy mode)

    if [[ "$proxy_status" == "'none'" ]]; then
        _proxyoff --local
    else
        _proxyon --local
    fi
}

# Redsocks transparent proxy redirection using system proxy host
_proxy_redsocks() {
  local command="$1"
  local ip="$2"
  
  case "$command" in
    enable)
      if [[ -z "$ip" ]]; then
        ip=$(gsettings get org.gnome.system.proxy.http host | tr -d "'")
      fi
      pkexec /usr/local/sbin/proxyredsocks enable "$ip"
      ;;
    disable)
      pkexec /usr/local/sbin/proxyredsocks disable
      ;;
    status)
      pkexec /usr/local/sbin/proxyredsocks status
      ;;
    *)
      echo -e "${_CLR_ERROR}Usage: proxy redsocks {enable|disable|status} [IP]${_CLR_RESET}"
      echo "Examples:"
      echo "  proxy redsocks enable             (uses system proxy)"
      echo "  proxy redsocks enable 172.31.1.100"
      echo "  proxy redsocks disable"
      echo "  proxy redsocks status"
      return 1
      ;;
  esac
}

# Display help information
_proxy_help() {
    cat << 'EOF'
Proxy Management Tool

USAGE:
  proxy <command> [subcommand] [options]

SHELL PROXY COMMANDS:
  proxy shell enable            Enable shell proxy based on system settings
                                Updates NetworkManager and DNF configurations (Use --local to avoid)
  proxy shell disable           Disable shell proxy
                                Restores NetworkManager and DNF configurations (Use --local to avoid)
  proxy shell configure         Auto-configure shell proxy based on system settings
                                Enables if system proxy mode is not 'none', disables otherwise
  proxy shell status            Show current shell proxy status

SYSTEM PROXY COMMANDS:
  proxy system set <IP>         Set system proxy (auto-prefixes 172.31)
                                Example: proxy system set 102.29
  proxy system enable           Set system proxy mode to manual
  proxy system disable          Set system proxy mode to none

REDSOCKS REDIRECTION COMMANDS:
  proxy redsocks enable [IP]    Enable transparent proxy redirection
                                IP: proxy IP (optional, defaults to system proxy)
  proxy redsocks disable        Disable transparent proxy redirection
  proxy redsocks status         Show transparent proxy status

GENERAL COMMANDS:
  proxy help                    Show this help message
EOF
}
