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

    nmasur.presets = {
      vm.enable = lib.mkDefault true;
      programs = {
        doas.enable = lib.mkDefault true;
      };
      services = {
        nix.enable = lib.mkDefault true;
      };
    };

    programs.fish.enable = lib.mkDefault config.home-manager.users.${username}.programs.fish.enable;

    # Allows us to declaritively set password
    users.mutableUsers = lib.mkDefault false;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.${username} = {
      # Use fish by default if enabled in home-manager
      shell = lib.mkIf (config.programs.fish.enable) pkgs.fish;

      # Create a home directory for human user
      isNormalUser = lib.mkDefault true;

      extraGroups = [
        "wheel" # Sudo privileges
      ];
    };

    # Basic common system packages for all devices
    environment.systemPackages = [
      pkgs.git
      pkgs.vim
      pkgs.wget
      pkgs.curl
      pkgs.home-manager
    ];

    # Extending time for home-manager build for things like nix-index cache
    systemd.services."home-manager-${username}" = {
      serviceConfig.TimeoutStartSec = lib.mkForce "45m";
    };

    allowUnfreePackages = config.home-manager.users.${username}.allowUnfreePackages;

    wsl.enable = lib.mkDefault false;

  };
}
