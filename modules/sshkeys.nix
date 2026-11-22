# Shared authorized SSH keys for every Den-managed OS user (NixOS + nix-darwin).
# Per-user keys use a unique aspect identity (fleet-demo ssh-keys pattern).
# Use the `user` class for account settings so they reach the host without
# den.batteries.user-aspects (den #694 / user-host-content migration).
{ ... }:
let
  keys = import ../sshkeys.nix;
in
{
  den.aspects.sshkeys = {
    description = "Provision shared authorized SSH keys from sshkeys.nix";
    os.users.users.root.openssh.authorizedKeys.keys = keys;
    includes = [
      (
        { host, user }:
        {
          name = "sshkeys/${user.userName}@${host.name}";
          user.openssh.authorizedKeys.keys = keys;
        }
      )
    ];
  };
}
