{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "terraform-init";
  runtimeInputs = [
    pkgs.gawk
    pkgs.git
    pkgs.terraform
  ];
  text = builtins.readFile ./terraform-init.sh;
}
