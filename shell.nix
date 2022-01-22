# Environment with formatting tools for editing these files
{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  nativeBuildInputs = [ pkgs.buildPackages.stylua pkgs.buildPackages.nixfmt ];
}
