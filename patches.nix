{ fetchpatch, fetchurl }:
[
  (fetchpatch {
    name = "nixos/security/wrappers: avoid linux-headers in closure";
    url = "https://github.com/NixOS/nixpkgs/pull/532581.patch";
    hash = "sha256-Tf3Lz9iQGqVVkviGg3FF2UyNVig8vhcYrMG+tIT2zA0=";
  })
  (fetchpatch {
    name = "grub-module-keep-booted-system-entry-option.patch";
    url = "https://github.com/NixOS/nixpkgs/pull/487895.patch";
    hash = "sha256-q4vOJ2BcNa+K0uWvhzuFvmOV7eVyWnKvD/CY3cGh5XI=";
  })
  (fetchpatch {
    name = "flyline: init at 1.11.0";
    url = "https://github.com/NixOS/nixpkgs/pull/538842.diff";
    hash = "sha256-x8NW+7+cNYHVj9FzUyRoCH7IdFJr7L7snd7R/h0rMvs=";
  })
  (fetchpatch {
    name = "disktree: skip test that fails on ZFS builders";
    url = "https://github.com/NixOS/nixpkgs/pull/588472.patch";
    hash = "sha256-vnfSH/MybFDjFocVA21W044EKlA/AO9KQQ7+YYvyVKw=";
  })
]
