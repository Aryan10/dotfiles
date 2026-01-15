# Redsocks System-wide Proxy Manager

Manages system-wide TCP traffic redirection through redsocks, enabling transparent proxying for applications that don't support proxy settings.

## Files

- **proxyredsocks.zsh** - Main proxy management script
- **90-proxyredsocks.rules.js** - PolicyKit authorization rule
- **redsocks.conf.template** - Redsocks configuration template

## Installation

1. Install the main script:
   ```bash
   sudo install -m 755 -o root -g root ~/.dotfiles/misc/proxyredsocks.zsh /usr/local/sbin/proxyredsocks
   ```

2. Install the PolicyKit rule:
   ```bash
   sudo install -m 644 -o root -g root ~/.dotfiles/misc/90-proxyredsocks.rules.js /etc/polkit-1/rules.d/90-proxyredsocks.rules
   sudo systemctl restart polkit
   ```

3. Install the redsocks configuration template:
   ```bash
   sudo install -m 644 -o root -g root ~/.dotfiles/misc/redsocks.conf.template /etc/redsocks.conf.template
   ```

