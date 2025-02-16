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
      enable = lib.mkDefault true;
      enable32Bit = lib.mkDefault true;
    };

    # Enable gamemode which can be executed on a per-game basis
    programs.gamemode.enable = lib.mkDefault true;

    environment.systemPackages = with pkgs; [ moonlight-qt ];

    nmasur.presets.programs = {
      steam.enable = lib.mkDefault true;
    };

  };
}
