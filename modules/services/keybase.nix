{ config, pkgs, lib, ... }: {

  services.keybase.enable = true;
  services.kbfs.enable = true;

  home-manager.users.${config.user} = {
    home.packages = [ (lib.mkIf config.gui.enable pkgs.keybase-gui) ];
    home.file = let
      ignorePatterns = ''
        keybase/
        kbfs/'';
    in {
      ".rgignore".text = ignorePatterns;
      ".fdignore".text = ignorePatterns;
    };
  };

}
