{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "docker-cleanup";
  runtimeInputs = [
    pkgs.docker-client
    pkgs.gawk
    pkgs.gnugrep
  ];
  text = builtins.readFile ./docker-cleanup.sh;
}
