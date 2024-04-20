# Derived from: https://github.com/jonascarpay/template-haskell
# More info here: https://jonascarpay.com/posts/2021-01-28-haskell-project-template.html

{
  description = "hello";

  inputs.haskellNix.url = "github:input-output-hk/haskell.nix";
  inputs.nixpkgs.follows = "haskellNix/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    {
      nixpkgs,
      flake-utils,
      haskellNix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlay = self: _: {
          hsPkgs = self.haskell-nix.project' rec {
            src = ./.;
            compiler-nix-name = "ghc8107";
            shell = {
              tools = {
                cabal = "latest";
                ghcid = "latest";
                haskell-language-server = "latest";
                hlint = "latest";
                # See https://github.com/input-output-hk/haskell.nix/issues/1337
                ormolu = {
                  version = "latest";
                  modules = [
                    (
                      { lib, ... }:
                      {
                        options.nonReinstallablePkgs = lib.mkOption { apply = lib.remove "Cabal"; };
                      }
                    )
                  ];
                };
              };
              ## ormolu that uses ImportQualifiedPost.
              ## To use, remove ormolu from the shell.tools section above, and uncomment the following lines.
              # buildInputs =
              #   let
              #     ormolu = pkgs.haskell-nix.tool compiler-nix-name "ormolu" "latest";
              #     ormolu-wrapped = pkgs.writeShellScriptBin "ormolu" ''
              #       ${ormolu}/bin/ormolu --ghc-opt=-XImportQualifiedPost $@
              #     '';
              #   in
              #   [ ormolu-wrapped ];
            };
          };
        };
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            haskellNix.overlay
            overlay
          ];
        };
        flake = pkgs.hsPkgs.flake { };
      in
      flake // { defaultPackage = flake.packages."hello:exe:hello-exe"; }
    );
}
