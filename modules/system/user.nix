{ config, lib, ... }: {

  options = {

    user = lib.mkOption {
      type = lib.types.str;
      description = "Primary user of the system";
      default = "nixos";
    };

    passwordHash = lib.mkOption {
      type = lib.types.str;
      description = "Password created with mkpasswd -m sha-512";
    };

  };

  config = {

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

    home-manager.users.${config.user}.xdg = {
      userDirs = {
        enable = true;
        createDirectories = true;
        documents = "$HOME/documents";
        download = "$HOME/downloads";
        music = "$HOME/media/music";
        pictures = "$HOME/media/images";
        videos = "$HOME/media/videos";
        desktop = "$HOME/other/desktop";
        publicShare = "$HOME/other/public";
        templates = "$HOME/other/templates";
        extraConfig = { XDG_DEV_DIR = "$HOME/dev"; };
      };
    };

  };

}
