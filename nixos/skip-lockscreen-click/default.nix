{
  config,
  lib,
  pkgs,
  ...
}:

let
  wantSkipClick = config.skip_lockscreen_click;
  wantPowerButtons = config.lockscreen_power_buttons;
in
{
  config = lib.mkIf (wantSkipClick || wantPowerButtons) {
    /*
      # Enforce concurrent PAM evaluation for kscreenlocker
      security.pam.services.kde-fingerprint = lib.mkIf config.services.fprintd.enable {
        fprintAuth = true;
        unixAuth = true; # Retains standard UNIX password verification as a parallel fallback
      };
    */

    environment.systemPackages =
      lib.optionals wantSkipClick [
        # SDDM Theme Override (hiPrio forces this file to overlay the original breeze theme)
        (lib.hiPrio (
          pkgs.runCommand "sddm-theme-breeze-override" { } ''
            mkdir -p $out/share/sddm/themes
            cp -r ${pkgs.kdePackages.plasma-desktop}/share/sddm/themes/breeze $out/share/sddm/themes/breeze
            chmod -R u+w $out

            # Apply patch to disable idle fadeout
            patch $out/share/sddm/themes/breeze/Main.qml < ${./sddm-breeze.patch}
          ''
        ))
      ]
      ++ [
        # Plasma Lockscreen Shield Bypass (+ optional power buttons)
        # Must copy ALL files — QML resolves relative imports (MainBlock, WallpaperFader, etc.)
        # from the file's store path, not the symlink location
        # One package applies every enabled patch so two overlays cannot fight over XDG_DATA_DIRS.
        (lib.hiPrio (
          pkgs.runCommand "plasma-lockscreen-bypass" { } ''
            mkdir -p $out/share/plasma/shells/org.kde.plasma.desktop/contents
            cp -r ${pkgs.kdePackages.plasma-desktop}/share/plasma/shells/org.kde.plasma.desktop/contents/lockscreen $out/share/plasma/shells/org.kde.plasma.desktop/contents/lockscreen
            chmod -R u+w $out

            ${lib.optionalString wantSkipClick ''
              # Apply patch to disable fadeouts and auto-trigger uiVisible after launch animation
              patch $out/share/plasma/shells/org.kde.plasma.desktop/contents/lockscreen/LockScreenUi.qml < ${./lockscreenui.patch}
            ''}

            ${lib.optionalString wantPowerButtons ''
              # Add Restart / Shut Down next to Sleep / Hibernate / Switch User
              patch $out/share/plasma/shells/org.kde.plasma.desktop/contents/lockscreen/LockScreenUi.qml < ${./lockscreenui-power-buttons.patch}
            ''}
          ''
        ))
      ];
  };
}
