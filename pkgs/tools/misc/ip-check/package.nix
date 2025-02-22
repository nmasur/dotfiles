{ pkgs, lib, ... }:

pkgs.writers.writeFishBin "ip-check" {
  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    "${lib.makeBinPath [ pkgs.curl ]}"
  ];
} (builtins.readFile ./ip.fish)
