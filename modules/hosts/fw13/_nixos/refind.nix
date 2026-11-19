# rEFInd bootloader configuration for fw13 — EXPERIMENTAL, replaces GRUB.
# Test: nixos-rebuild switch, then check `efibootmgr -v` for a "rEFInd" entry.
# Rollback to GRUB: rename this file to refind.nix.disabled, rename
# grub.nix.disabled back to grub.nix, and swap the import in ./default.nix.
# options: https://search.nixos.org/options?channel=unstable&query=rEFInd
{ pkgs, ... }:
{
  boot.loader = {
    timeout = 3;
    # this nixpkgs defaults grub.enable to !boot.isContainer (i.e. true on bare
    # metal), so GRUB has to be switched off explicitly or its devices
    # assertion fails once grub.nix is gone.
    grub.enable = false;
    refind = {
      enable = true;
      maxGenerations = 5;
      # rEFInd auto-detects Windows (EFI/Microsoft/Boot/bootmgfw.efi) and other
      # loaders on the same ESP, so grub's useOSProber has no equivalent here.
      # grub's `default = "saved"` (remember last entry) also has no equivalent.
      additionalFiles = {
        # replaces grub.memtest86.enable; rEFInd lists its tools directory
        "EFI/refind/tools/mt86plus.efi" = "${pkgs.memtest86plus}/mt86plus.efi";
      };
      extraConfig = ''
        # UEFI pointer input, disabled by default in rEFInd.
        # enable_touch and enable_mouse are mutually exclusive; enable one if
        # you want tap/click instead of arrow keys on the FW13 panel.
        #enable_touch
        #enable_mouse
      '';
    };
    efi.canTouchEfiVariables = true;
  };
}
