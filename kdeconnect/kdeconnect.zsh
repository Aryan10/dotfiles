# KDE Connect firewall fix for hotspot (nm-shared zone)
# Adds kdeconnect service at runtime so phone can discover laptop over hotspot.
# This is a runtime-only rule — resets every reboot, re-applied on first terminal open.
if ! firewall-cmd --zone=nm-shared --query-service=kdeconnect &>/dev/null; then
    sudo firewall-cmd --zone=nm-shared --add-service=kdeconnect &>/dev/null && \
fi
