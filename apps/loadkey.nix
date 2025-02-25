{ pkgs, ... }:
{

  # TODO: just replace with packages instead of apps

  type = "app";

  program = "${pkgs.nmasur.loadkey}/bin/loadkey";
}
