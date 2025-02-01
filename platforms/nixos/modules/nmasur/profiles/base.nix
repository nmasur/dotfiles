{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.profiles.base;
in

{

  options.nmasur.profiles.base.enable = lib.mkEnableOption "base Linux config";

  config = lib.mkIf cfg.enable {

    # Allows us to declaritively set password
    users.mutableUsers = lib.mkDefault false;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.${config.user} = {

      # Create a home directory for human user
      isNormalUser = lib.mkDefault true;

      # Automatically create a password to start
      hashedPassword = lib.mkDefault config.passwordHash;

      extraGroups = lib.mkDefault [
        "wheel" # Sudo privileges
      ];
    };

    # Include home-manager config in NixOS
    home-manager = {
      sharedModules = [ ../../../../home-manager ];

      # Use the system-level nixpkgs instead of Home Manager's
      useGlobalPkgs = lib.mkDefault true;

      # Install packages to /etc/profiles instead of ~/.nix-profile, useful when
      # using multiple profiles for one user
      useUserPackages = lib.mkDefault true;

    };

  };
}
