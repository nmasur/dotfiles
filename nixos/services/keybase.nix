{ config, pkgs, lib, ... }: {

  options.keybase.enable = lib.mkEnableOption "Keybase.";

  config = lib.mkIf config.keybase.enable {

    services.keybase.enable = true;
    services.kbfs = {
      enable = true;
      # enableRedirector = true;
      mountPoint = "/run/user/1000/keybase/kbfs";
    };
    security.wrappers.keybase-redirector = {
      setuid = true;
      owner = "root";
      group = "root";
      source = "${pkgs.kbfs}/bin/redirector";
    };

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

  };

}
