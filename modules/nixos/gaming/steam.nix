{ config, pkgs, lib, ... }: {

  options.gaming.steam.enable = lib.mkEnableOption "Steam game launcher.";

  config = lib.mkIf (config.gaming.steam.enable && pkgs.stdenv.isLinux) {
    hardware.steam-hardware.enable = true;
    unfreePackages = [ "steam" "steam-original" "steamcmd" "steam-run" ];

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };

    environment.systemPackages = with pkgs; [

      # Enable terminal interaction
      steamPackages.steamcmd
      steam-tui

      # Allow downloading of GE-Proton and other versions
      protonup-qt

    ];

    # Adapted in part from: https://github.com/Shawn8901/nix-configuration/blob/1c48be94238a9f463cf0bbd1e1842a4454286514/modules/nixos/steam-compat-tools/default.nix
    # Based on: https://github.com/NixOS/nixpkgs/issues/73323
    environment.sessionVariables.STEAM_EXTRA_COMPAT_TOOLS_PATHS =
      lib.makeBinPath [ pkgs.proton-ge-custom ];

    # Seems like NetworkManager can help speed up Steam launch
    # https://www.reddit.com/r/archlinux/comments/qguhco/steam_startup_time_arch_1451_seconds_fedora_34/hi8opet/
    networking.networkmanager.enable = true;

  };

}
