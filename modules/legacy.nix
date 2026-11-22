{ den, ... }: {
  den.schema.host.includes = [
    (den.batteries.import-tree.provides.host ./hosts)
    # Explicit for den #694: keep provides.to-hosts after the 2027-01-01 cutover.
    den.batteries.mutual-provider
  ];
  den.default.includes = [
    den.aspects.sshkeys
    den.aspects.bandaid
  ];
}
