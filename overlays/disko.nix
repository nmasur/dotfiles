# Add disko to nixpkgs from its input flake

inputs: _final: prev: { disko = inputs.disko.packages.${prev.system}.disko; }
