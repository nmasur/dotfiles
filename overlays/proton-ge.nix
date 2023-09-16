# Adapted from:
# https://github.com/Shawn8901/nix-configuration/blob/182a45a6b193143ff7ff8e78bb66f7b869ea48d4/packages/proton-ge-custom/default.nix
# Based on: https://github.com/NixOS/nixpkgs/issues/73323

inputs: _final: prev: {
  proton-ge-custom = prev.stdenv.mkDerivation (finalAttrs: rec {
    name = "proton-ge-custom";
    version = "0.1"; # Made up
    src = inputs.proton-ge;
    installPhase = ''
      mkdir -p $out/bin
      cp -r ${src}/* -t $out/bin/
    '';
  });
}
