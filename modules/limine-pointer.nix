{ den, ... }:
{
  den.aspects.limine-pointer = {
    description = "Limine mouse/touchscreen input + touch-friendly HiDPI menu";
    nixos = {
      # Limine ≥12.5: UEFI Absolute/Simple Pointer (mouse + touchscreen).
      # Left-click / tap selects or boots; scroll wheel moves selection;
      # pointer use pauses the timeout countdown (same as a keypress).
      boot.loader.limine.extraConfig = ''
        mouse: yes
      '';

      boot.loader.limine.style = {
        # Dark solid backdrop — same idea as former GRUB stylish+black.png
        wallpapers = [ ../nixos/black.png ];
        wallpaperStyle = "stretched";
        backdrop = "000000";

        interface = {
          # Keybind strip is keyboard-oriented; hide for a cleaner touch UI
          helpHidden = true;
        };

        graphicalTerminal = {
          enable = true;
          # Native FW13 panels are HiDPI; auto scale is often too small for
          # finger targets (≈32px row height at 2x2). 3x3 ≈48px rows.
          font.scale = "3x3";
          font.spacing = 2;
          margin = 96;
          marginGradient = 8;
        };
      };
    };
  };
}
