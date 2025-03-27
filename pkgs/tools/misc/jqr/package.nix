{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "jqr";
  runtimeInputs = [
    pkgs.jq
    pkgs.fzf
  ];
  text = builtins.readFile ./jqr.sh;
}
