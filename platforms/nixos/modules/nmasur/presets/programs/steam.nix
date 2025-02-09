{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.steam;
in

{

  options.nmasur.presets.programs.steam.enable = lib.mkEnableOption "Steam game client";

  config = lib.mkIf cfg.enable {
    hardware.steam-hardware.enable = true;
    allowUnfreePackages = [
      "steam"
      "steam-original"
      "steamcmd"
      "steam-run"
      "steam-unwrapped"
    ];

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
      gamescopeSession.enable = true;
    };

    environment.systemPackages = with pkgs; [

      # Enable terminal interaction
      steamcmd
      steam-tui

      # Overlay with performance monitoring
      mangohud
    ];

    # Seems like NetworkManager can help speed up Steam launch
    # https://www.reddit.com/r/archlinux/comments/qguhco/steam_startup_time_arch_1451_seconds_fedora_34/hi8opet/
    networking.networkmanager.enable = true;

  };
}
