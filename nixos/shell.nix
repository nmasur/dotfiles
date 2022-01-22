{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  nativeBuildInputs = [ pkgs.buildPackages.stylua pkgs.buildPackages.nixfmt ];
}
