{ config, pkgs, lib, ... }:

let home-packages = config.home-manager.users.${config.user}.home.packages;

in {

  imports = [ ./. ];

  config = {
    environment.systemPackages = with pkgs; [
      legendary-gl
      rare # GUI for Legendary (not working)
      wineWowPackages.stable # 32-bit and 64-bit wineWowPackages, see https://nixos.wiki/wiki/Wine
    ];

    home-manager.users.${config.user} = {

      xdg.configFile."legendary/config.ini".text = ''
        [Legendary]
        ; Disables the automatic update check
        disable_update_check = false
        ; Disables the notice about an available update on exit
        disable_update_notice = true
        ; Set install directory
        install_dir = ${config.homePath}/media/games
        ; Make output quiet
        log_level = error
      '';

      home.file = let
        ignorePatterns = ''
          .wine/
          drive_c/'';
      in {
        ".rgignore".text = ignorePatterns;
        ".fdignore".text = ignorePatterns;
      };

      programs.fish.functions =
        lib.mkIf (builtins.elem pkgs.fzf home-packages) {
          epic-games = {
            body = ''
              set game (legendary list 2>/dev/null \
                  | awk '/^ \* / { print $0; }' \
                  | sed -e 's/ (.*)$//' -e 's/ \* //' \
                  | fzf)
              and legendary launch "$game" &> /dev/null
            '';
          };
        };

    };
  };

}
