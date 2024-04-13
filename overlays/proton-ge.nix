# Adapted from:
# https://github.com/Shawn8901/nix-configuration/blob/182a45a6b193143ff7ff8e78bb66f7b869ea48d4/packages/proton-ge-custom/default.nix
# Based on: https://github.com/NixOS/nixpkgs/issues/73323

inputs: _final: prev: {
  proton-ge-custom = prev.stdenv.mkDerivation (finalAttrs: rec {
    name = "proton-ge-custom";
    version = prev.lib.removeSuffix "\n" (
      builtins.head (builtins.match ".*GE-Proton(.*)" (builtins.readFile "${inputs.proton-ge}/version"))
    );
    src = inputs.proton-ge;
    # Took from https://github.com/AtaraxiaSjel/nur/blob/cf83b14b102985a587a498ba2c56f9f2bd9b9eb6/pkgs/proton-ge/default.nix
    installPhase = ''
      runHook preBuild
      mkdir -p $out/bin
      cp -r ${src}/* -t $out/bin/
      runHook postBuild
    '';
  });
}
