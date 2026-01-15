# 
sudo install -m 755 -o root -g root ~/.dotfiles/proxy/proxyredsocks.sh /usr/local/sbin/proxyredsocks

# 
sudo install -m 644 -o root -g root ~/.dotfiles/proxy/90-proxyredsocks.rules.js /etc/polkit-1/rules.d/90-proxyredsocks.rules
sudo systemctl restart polkit

# 
sudo install -m 644 -o root -g root ~/.dotfiles/proxy/redsocks.conf.template /etc/redsocks.conf.template