# Install cli scripts
sudo install -m 755 -o root -g root ~/.dotfiles/proxy/proxyredsocks.sh /usr/local/sbin/proxyredsocks
sudo install -m 755 -o root -g root ~/.dotfiles/proxy/masquerade.sh /usr/local/sbin/masquerade

# Install polkit rules
sudo install -m 644 -o root -g root ~/.dotfiles/proxy/90-proxyredsocks.rules.js /etc/polkit-1/rules.d/90-proxyredsocks.rules
sudo install -m 644 -o root -g root ~/.dotfiles/proxy/90-masquerade.rules.js /etc/polkit-1/rules.d/90-masquerade.rules
sudo systemctl restart polkit

# Install redsocks configuration template
sudo install -m 644 -o root -g root ~/.dotfiles/proxy/redsocks.conf.template /etc/redsocks.conf.template

# Install redsocks2 binary
sudo install -Dm755 ~/.dotfiles/proxy/bin/redsocks2 /usr/local/bin/redsocks
 
# Install redsocks systemd service
sudo install -Dm644 ~/.dotfiles/proxy/redsocks.service /etc/systemd/system/redsocks.service

# Enable the service
sudo systemctl daemon-reload
sudo systemctl enable redsocks