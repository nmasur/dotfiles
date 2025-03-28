{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.fish;
  inherit (config.nmasur.settings) username;
in

{

  options.nmasur.presets.programs.fish.enable = lib.mkEnableOption "Fish shell";

  config = lib.mkIf cfg.enable {
    programs.fish.enable = true;

    environment.shells = [ pkgs.fish ];

    users.users.${username}.shell = pkgs.fish;

    # Speeds up fish launch time on macOS
    programs.fish.useBabelfish = true;
  };
}
