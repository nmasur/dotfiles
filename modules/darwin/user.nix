{
  config,
  pkgs,
  lib,
  ...
}:
{

  config = lib.mkIf pkgs.stdenv.isDarwin {

    users.users."${config.user}" = {
      # macOS user
      home = config.homePath;
      uid = 502;
      # shell = pkgs.fish; # Default shell
    };

    # This might fix the shell issues
    users.knownUsers = [ config.user ];

    home-manager.users.${config.user} = {

      # Default shell setting doesn't work
      home.sessionVariables = {
        SHELL = "${pkgs.fish}/bin/fish";
      };

      # Used for aerc
      xdg.enable = true;
    };

    # Fix for: 'Error: HOME is set to "/var/root" but we expect "/var/empty"'
    home-manager.users.root.home.homeDirectory = lib.mkForce "/var/root";
  };
}
