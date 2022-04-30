{ pkgs, lib, identity, gui, ... }: {

  services.keybase.enable = true;
  services.kbfs.enable = true;

  home-manager.users.${identity.user} = {
    home.packages = [ (lib.mkIf gui.enable pkgs.keybase-gui) ];
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
