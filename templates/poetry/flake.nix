{
  description = "Python project flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    poetry2nix.url = "github:nix-community/poetry2nix";
  };
  outputs =
    { nixpkgs, poetry2nix, ... }:
    let
      projectDir = ./.;
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ poetry2nix.overlays.default ];
          };
        in
        {
          default = pkgs.poetry2nix.mkPoetryApplication { inherit projectDir; };
        }
      );
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ poetry2nix.overlays.default ];
          };
        in
        {
          default = pkgs.mkShell {
            buildInputs = [
              (pkgs.poetry2nix.mkPoetryEnv { inherit projectDir; })
              pkgs.poetry
            ];
          };
        }
      );
    };
}
