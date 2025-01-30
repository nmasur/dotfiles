{ pkgs, ... }:
{

  # TODO: just replace with packages instead of apps

  type = "app";

  program = "${pkgs.loadkey}/bin/loadkey";
}
