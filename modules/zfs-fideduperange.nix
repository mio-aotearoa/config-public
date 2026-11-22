{
  den.aspects.zfs-fideduperange = {
    description = "Backport OpenZFS FIDEDUPERANGE block cloning to the selected ZFS kernel module";
    nixos =
      { config, pkgs, ... }:
      let
        inherit (config.boot) kernelPackages;
        zfsModule = kernelPackages.${config.boot.zfs.package.kernelModuleAttribute};
        upstream = pkgs.fetchurl {
          name = "Implement-FIDEDUPERANGE-via-block-cloning.patch";
          url = "https://github.com/openzfs/zfs/commit/afb4010325a52413c0ad813885eed50738a8380b.patch";
          hash = "sha256-OXMXf5Ix5+fbi39kAGOx74BmdepDGIrj3F6sJxok0Po=";
        };
        backport = pkgs.runCommand "zfs-2.4.4-fideduperange.patch" { } ''
          ${pkgs.buildPackages.patch}/bin/patch --output="$out" ${upstream} < ${./_zfs-fideduperange/zfs-2.4.4.patch.patch}
        '';
      in
      {
        boot.zfs.modulePackage = zfsModule.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [ backport ];
        });
      };
  };
}
