{ pkgs, ... }:
{

  # This script will partition and format drives; use at your own risk!

  type = "app";

  program = pkgs.lib.getExe pkgs.format-root;
}
