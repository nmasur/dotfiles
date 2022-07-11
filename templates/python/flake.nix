{
  description = "Python pip flake";

  inputs.mach-nix.url = "github:DavHau/mach-nix/3.5.0";

  outputs = { self, nixpkgs, mach-nix }@inp:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f:
        nixpkgs.lib.genAttrs supportedSystems
        (system: f system (import nixpkgs { inherit system; }));
    in rec {
      defaultApp = forAllSystems (system: pkgs:
        mach-nix.lib."${system}".mkPython {
          requirements = builtins.readFile ./requirements.txt;
        });
      devShell = forAllSystems (system: pkgs:
        pkgs.mkShell { buildInputs = [ defaultApp."${system}" ]; });
    };
}
