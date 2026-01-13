// File Location: /etc/polkit-1/rules.d/90-proxyredsocks.rules
/* Update the policy kit rule with:
  sudo install -m 644 -o root -g root ~/.dotfiles/0/90-proxyredsocks.rules.js /etc/polkit-1/rules.d/90-proxyredsocks.rules
  sudo systemctl restart polkit
*/

polkit.addRule(function (action, subject) {
  if (
    action.id == "org.freedesktop.policykit.exec" &&
    action.lookup("program") == "/usr/local/sbin/proxyredsocks" &&
    subject.active === true &&
    subject.local === true
  ) {
    return polkit.Result.YES;
  }
});
