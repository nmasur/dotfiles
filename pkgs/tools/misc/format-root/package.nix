{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "format-root";
  runtimeInputs = [
    pkgs.gum
    pkgs.disko
  ];
  text = builtins.readFile ./format-root.sh;
}
