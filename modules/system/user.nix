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

  };

}
