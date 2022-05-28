{ config, pkgs, lib, ... }: {

  options.gaming.legendary =
    lib.mkEnableOption "Legendary - Epic Games Launcher";

  config = lib.mkIf config.gaming.legendary {
    environment.systemPackages = with pkgs; [
      legendary-gl
      rare # GUI for Legendary (not working)
      wineWowPackages.stable # 32-bit and 64-bit wineWowPackages
    ];

    home-manager.users.${config.user} = {

      xdg.configFile."legendary/config.ini".text = ''
        [Legendary]
        ; Disables the automatic update check
        disable_update_check = false
        ; Disables the notice about an available update on exit
        disable_update_notice = true
        ; Set install directory
        install_dir = /home/${config.user}/media/games
        ; Make output quiet
        log_level = warning
      '';

      home.file = let
        ignorePatterns = ''
          .wine/
          drive_c/'';
      in {
        ".rgignore".text = ignorePatterns;
        ".fdignore".text = ignorePatterns;
      };

    };
  };

}
