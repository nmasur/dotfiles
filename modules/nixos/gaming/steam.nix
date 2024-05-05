{
  config,
  pkgs,
  lib,
  ...
}:
{

  options.gaming.steam.enable = lib.mkEnableOption "Steam game launcher.";

  config = lib.mkIf (config.gaming.steam.enable && pkgs.stdenv.isLinux) {
    hardware.steam-hardware.enable = true;
    unfreePackages = [
      "steam"
      "steam-original"
      "steamcmd"
      "steam-run"
    ];

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
      gamescopeSession.enable = true;
    };

    environment.systemPackages = with pkgs; [

      # Enable terminal interaction
      steamPackages.steamcmd
      steam-tui

      # Overlay with performance monitoring
      mangohud
    ];

    # Seems like NetworkManager can help speed up Steam launch
    # https://www.reddit.com/r/archlinux/comments/qguhco/steam_startup_time_arch_1451_seconds_fedora_34/hi8opet/
    networking.networkmanager.enable = true;
  };
}
