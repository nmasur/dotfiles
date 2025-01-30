{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.profiles.gaming;
in

{

  options.nmasur.profiles.gaming.enable = lib.mkEnableOption "gaming options";

  config = lib.mkIf cfg.enable {

    # Enable graphics acceleration
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # Enable gamemode which can be executed on a per-game basis
    programs.gamemode.enable = true;

    environment.systemPackages = with pkgs; [ moonlight-qt ];

  };
}
