{ den, ... }:
{
  den.aspects.nixbuild-always = {
    includes = [
      den.aspects.nixbuild
    ];
    description = "Always route builds to nixbuild.net (distributed buildMachines)";
    os =
      { ... }:
      {
        nix = {
          distributedBuilds = true;
          buildMachines = [
            {
              hostName = "eu.nixbuild.net";
              system = "x86_64-linux";
              maxJobs = 100;
              supportedFeatures = [
                "benchmark"
                "big-parallel"
              ];
            }
            {
              hostName = "eu.nixbuild.net";
              system = "armv7l-linux";
              maxJobs = 100;
              supportedFeatures = [
                "benchmark"
                "big-parallel"
                "gccarch-armv7-a"
              ];
            }
          ];
        };
      };
  };
}
