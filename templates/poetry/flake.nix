{
  description = "Python project flake";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.poetry2nix.url = "github:nix-community/poetry2nix";

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      poetry2nix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ poetry2nix.overlay ];
        };
        projectDir = ./.;
      in
      {
        defaultPackage = pkgs.poetry2nix.mkPoetryApplication { inherit projectDir; };
        devShells.default = pkgs.mkShell {
          buildInputs = [
            (pkgs.poetry2nix.mkPoetryEnv { inherit projectDir; })
            pkgs.poetry
          ];
        };
      }
    );
}
