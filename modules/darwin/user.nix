{ config, pkgs, lib, ... }: {

  config = lib.mkIf pkgs.stdenv.isDarwin {

    users.users."${config.user}" = {
      # macOS user
      home = config.homePath;
      shell = pkgs.fish; # Default shell

    };

    # Used for aerc
    home-manager.users.${config.user}.xdg.enable = true;

  };

}
