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
    name = "flyline: init at 1.9.0";
    url = "https://github.com/NixOS/nixpkgs/pull/538842.patch";
    hash = "sha256-pLZkfWWQ1zRo/i9EGkV6c8vh1CyXRR8HH3u53dEBcvM=";
  })
  (fetchpatch {
    name = "{libisofs,libburn,libisoburn}: adopt, modernize, cleanup";
    url = "https://github.com/NixOS/nixpkgs/pull/589558.patch";
    hash = "sha256-/clnXuYh7j0er4yxCgFW3lZ1K8NL08YCuEXIXOrvhM0=";
  })
  /*
    (fetchpatch {
      name = "isabelle: 2025-2 -> 2026";
      url = "https://github.com/NixOS/nixpkgs/pull/579996.patch";
      hash = "sha256-ubCIGJtM1fBr/KzCi2G2zzFi6KohbEkFVv6saUQ3yow=";
    })
  */
]
