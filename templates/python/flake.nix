{
  description = "Python pip flake";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        pythonEnv = pkgs.python310.withPackages (pypi:
          with pypi;
          [
            # Add requirements here
            requests
          ]);
      in {
        devShells.default = pkgs.mkShell { buildInputs = [ pythonEnv ]; };
      });
}
