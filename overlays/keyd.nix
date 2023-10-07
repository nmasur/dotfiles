# Use latest PR of keyd to update to 2.4.3
# https://github.com/NixOS/nixpkgs/pull/245327

inputs: _final: prev: {
  inherit (inputs.nixpkgs-keyd.legacyPackages.${prev.system}) keyd;
}
