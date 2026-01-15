polkit.addRule(function (action, subject) {
  // Authorize the proxyredsocks script execution without password prompt
  if (
    action.id == "org.freedesktop.policykit.exec" &&
    action.lookup("program") == "/usr/local/sbin/proxyredsocks" &&
    subject.active === true && // User has active session
    subject.local === true // Local session (not remote SSH)
  ) {
    return polkit.Result.YES; // Allow without authentication
  }
});
