{
  config,
  pkgs,
  lib,
  ...
}:
{

  options = {

    passwordHash = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "Password created with mkpasswd -m sha-512";
      default = null;
      # Test it by running: mkpasswd -m sha-512 --salt "PZYiMGmJIIHAepTM"
    };
  };

  config = {

    # Allows us to declaritively set password
    users.mutableUsers = false;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.${config.user} = {

      # Create a home directory for human user
      isNormalUser = true;

      # Automatically create a password to start
      hashedPassword = config.passwordHash;

      extraGroups = [
        "wheel" # Sudo privileges
      ];
    };

    # Allow writing custom scripts outside of Nix
    # Probably shouldn't make this a habit
    environment.localBinInPath = true;

    home-manager.users.${config.user}.xdg = {

      # Allow Nix to manage the default applications list
      mimeApps.enable = true;

      # Create a desktop option for Burp
      desktopEntries.burp = lib.mkIf pkgs.stdenv.isLinux {
        name = "Burp";
        exec = "${config.homePath}/.local/bin/burp.sh";
        categories = [ "Application" ];
      };

      # Set directories for application defaults
      userDirs = {
        enable = true;
        createDirectories = true;
        documents = "$HOME/documents";
        download = config.userDirs.download;
        music = "$HOME/media/music";
        pictures = "$HOME/media/images";
        videos = "$HOME/media/videos";
        desktop = "$HOME/other/desktop";
        publicShare = "$HOME/other/public";
        templates = "$HOME/other/templates";
        extraConfig = {
          XDG_DEV_DIR = "$HOME/dev";
        };
      };
    };
  };
}
