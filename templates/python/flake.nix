{
  description = "Python pip flake";

  inputs.mach-nix.url = "github:mach-nix/3.5.0";

  outputs = { self, nixpkgs, mach-nix }@inp:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f:
        nixpkgs.lib.genAttrs supportedSystems
        (system: f system (import nixpkgs { inherit system; }));
    in {
      devShell = forAllSystems (system: pkgs:
        mach-nix.lib."${system}".mkPythonShell {
          requirements = builtins.readFile ./requirements.txt;
        });
    };
}
