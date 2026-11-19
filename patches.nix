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
    name = "mesh-llm, skippy-native-runtime: init at 0.80.0";
    url = "https://github.com/NixOS/nixpkgs/pull/571722.diff";
    hash = "sha256-5pmW5KLE/p4C5Do1pfXQ5v8u7+0iZIiohszNDANAtcc=";
  })
  /*
    (fetchpatch {
      name = "isabelle: 2025-2 -> 2026";
      url = "https://github.com/NixOS/nixpkgs/pull/579996.patch";
      hash = "sha256-ubCIGJtM1fBr/KzCi2G2zzFi6KohbEkFVv6saUQ3yow=";
    })
  */
  (fetchpatch {
    name = "telegram-desktop: 7.4.3 -> 7.4.4";
    url = "https://github.com/NixOS/nixpkgs/pull/587822.patch";
    hash = "sha256-s15ZtF79+ESVA/5wlyVyJNV60KYg3did7uXeMmnLkis=";
  })
]
