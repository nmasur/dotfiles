{
  description = "Python pip flake";

  inputs.pypi-deps-db = {
    url = "github:DavHau/pypi-deps-db/b8c61fb930c9a9f95057b717bc7c701196f2ee4e";
    flake = false;
  };
  inputs.mach-nix = {
    # url = "github:DavHau/mach-nix/3.5.0";
    url = "github:DavHau/mach-nix/8d903072c7b5426d90bc42a008242c76590af916";
    inputs.pypi-deps-db.follows = "pypi-deps-db";
  };

  outputs =
    { nixpkgs, mach-nix, ... }:
    let
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems =
        f: nixpkgs.lib.genAttrs supportedSystems (system: f system (import nixpkgs { inherit system; }));
    in
    rec {
      defaultApp = forAllSystems (
        system: _pkgs:
        mach-nix.lib."${system}".mkPython { requirements = builtins.readFile ./requirements.txt; }
      );
      devShell = forAllSystems (system: pkgs: pkgs.mkShell { buildInputs = [ defaultApp."${system}" ]; });
    };
}
