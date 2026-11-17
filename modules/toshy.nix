# Toshy keyboard remapping with Command on physical Meta (den.aspects.toshy).
{ den, ... }:
{
  den.aspects.toshy = {
    description = "Toshy with Meta copy and paste";
    nixos =
      {
        config,
        inputs,
        lib,
        ...
      }:
      {
        imports = [ inputs.mio.nixosModules.toshy ];

        services.toshy = {
          enable = lib.mkDefault true;
          users = lib.attrNames config.home-manager.users;
        };
        home-manager.sharedModules = [
          inputs.mio.homeModules.toshy
          ({ pkgs, ... }: {
            services.toshy = {
              enable = lib.mkDefault config.services.toshy.enable;
              package = inputs.mio.packages.${pkgs.stdenv.hostPlatform.system}.toshy;
              # Keep Command on physical Meta, including on PC keyboards.
              keyboardType = lib.mkDefault "Apple";
              installKwinScript = lib.mkDefault config.services.desktopManager.plasma6.enable;
            };
            # Wayland needs window context to distinguish terminals from GUI apps.
            home.packages =
              lib.mkIf (config.services.toshy.enable && config.services.desktopManager.gnome.enable)
                [
                  pkgs.gnomeExtensions.xremap
                ];
            dconf.settings =
              lib.mkIf (config.services.toshy.enable && config.services.desktopManager.gnome.enable)
                {
                  "org/gnome/shell".enabled-extensions = [ pkgs.gnomeExtensions.xremap.extensionUuid ];
                };
          })
        ];
      };
  };
}
