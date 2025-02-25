{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.nmasur.settings) username;
  cfg = config.nmasur.profiles.base;
in

{

  options.nmasur.profiles.base.enable = lib.mkEnableOption "base Linux config";

  config = lib.mkIf cfg.enable {

    nmasur.presets.services = {
      # Allow tunneling into the machine
      cloudflared.enable = lib.mkDefault true;
      openssh.enable = lib.mkDefault true;
    };

    # Allows us to declaritively set password
    users.mutableUsers = lib.mkDefault false;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.${username} = {

      # Create a home directory for human user
      isNormalUser = lib.mkDefault true;

      extraGroups = lib.mkDefault [
        "wheel" # Sudo privileges
      ];
    };

    # Basic common system packages for all devices
    environment.systemPackages = [
      pkgs.git
      pkgs.vim
      pkgs.wget
      pkgs.curl
    ];

    # Include home-manager config in NixOS
    home-manager = {
      sharedModules = [ ../../../../home-manager ];

      # Use the system-level nixpkgs instead of Home Manager's
      useGlobalPkgs = lib.mkDefault true;

      # Install packages to /etc/profiles instead of ~/.nix-profile, useful when
      # using multiple profiles for one user
      useUserPackages = lib.mkDefault true;

    };

    allowUnfreePackages = config.home-manager.users.${username}.allowUnfreePackages;

  };
}
