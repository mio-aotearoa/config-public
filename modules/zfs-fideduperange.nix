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
        tests = pkgs.fetchurl {
          name = "ZTS-Add-FIDEDUPERANGE-tests.patch";
          url = "https://github.com/openzfs/zfs/commit/6904037d7dab4efe118fade6a67e8b935617bf09.patch";
          hash = "sha256-TbYDBdvgk0MyfzbbpLz0EMfrX+WdTUNiDwoWiQFFWuA=";
        };
        patchedModule = zfsModule.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [
            backport
            tests
          ];
        });
      in
      {
        boot.zfs.modulePackage = patchedModule;
        system.build.zfsFideduperangeTestSource = pkgs.applyPatches {
          name = "zfs-${patchedModule.version}-fideduperange-test-source";
          inherit (patchedModule) src patches;
        };
      };
  };
}
