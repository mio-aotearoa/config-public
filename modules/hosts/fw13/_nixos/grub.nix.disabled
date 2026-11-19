# GRUB bootloader configuration for fw13.
{ ... }:
{
  boot.loader = {
    timeout = 3;
    grub.enable = true;
    grub.memtest86.enable = true;
    grub.configurationLimit = 5;
    # https://nixos.wiki/wiki/Dual_Booting_NixOS_and_Windows
    grub.useOSProber = true;
    # https://discourse.nixos.org/t/question-about-grub-and-nodev/37867
    grub.device = "nodev";
    # https://www.reddit.com/r/NixOS/comments/klahwf/comment/kt10tt8
    grub.default = "saved";
    #sagrub.default = "'Windows Boot Manager'";
    grub.efiSupport = true;
    efi.canTouchEfiVariables = true;
    grub2-theme = {
      enable = true;
      #splashImage = config.system_background; # unable to see menu clearly with this image
      splashImage = ../../../../nixos/black.png;
      theme = "stylish";
      #theme = "whitesur";
      #icon = "whitesur";
      footer = true;
      screen = "4k";
    };
  };
}
