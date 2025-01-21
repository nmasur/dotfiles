{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.nmasur.profiles.developer;
in

{

  options.nmasur.profiles.developer.enable = lib.mkEnableOption "Developer tools";

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      pgcli # Postgres client with autocomplete
    ];

  };

}
