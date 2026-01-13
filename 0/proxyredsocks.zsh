#!/usr/bin/env bash

# File Location: /usr/local/sbin/proxyredsocks
# Update: sudo install -m 755 -o root -g root  ~/.dotfiles/0/proxyredsocks.zsh /usr/local/sbin/proxyredsocks

set -euo pipefail

PORT=12345
CHAIN=REDSOCKS
SERVICE=redsocks

case "$1" in
  on)
    systemctl start $SERVICE

    iptables -t nat -N $CHAIN 2>/dev/null || true
    iptables -t nat -F $CHAIN

    for net in \
      0.0.0.0/8 \
      10.0.0.0/8 \
      127.0.0.0/8 \
      169.254.0.0/16 \
      172.16.0.0/12 \
      192.168.0.0/16 \
      224.0.0.0/4 \
      240.0.0.0/4; do
      iptables -t nat -A $CHAIN -d $net -j RETURN
    done

    iptables -t nat -A $CHAIN -p tcp -j REDIRECT --to-port $PORT
    iptables -t nat -C OUTPUT -p tcp -j $CHAIN 2>/dev/null || \
      iptables -t nat -A OUTPUT -p tcp -j $CHAIN

    iptables -C OUTPUT -p udp --dport 443 -j DROP 2>/dev/null || \
      iptables -A OUTPUT -p udp --dport 443 -j DROP
    ;;
  off)
    iptables -t nat -D OUTPUT -p tcp -j $CHAIN 2>/dev/null || true
    iptables -t nat -F $CHAIN 2>/dev/null || true
    iptables -t nat -X $CHAIN 2>/dev/null || true
    iptables -D OUTPUT -p udp --dport 443 -j DROP 2>/dev/null || true
    systemctl stop $SERVICE
    ;;
  status)
    systemctl is-active $SERVICE
    ;;
  *)
    exit 1
esac
