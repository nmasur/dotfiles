{ config, lib, pkgs, ... }: {

  imports = [
    ../modules/hardware
    ../modules/system
    ../modules/graphical
    ../modules/shell
    ../modules/gaming
    ../modules/applications
    ../modules/editor
    ../modules/mail/himalaya.nix
  ];

  options = with lib; {
    dotfilesPath = mkOption {
      type = types.path;
      description = "Path of dotfiles repository.";
      default = builtins.toPath "/home/${config.user}/dev/personal/dotfiles";
    };
    dotfilesRepo = mkOption {
      type = types.str;
      description = "Link to dotfiles repository.";
    };
    unfreePackages = mkOption {
      type = types.listOf types.str;
      description = "List of unfree packages to allow.";
      default = [ ];
    };
  };

  config = {

    # Enable features in Nix commands
    nix.extraOptions = "experimental-features = nix-command flakes";

    # Basic common system packages for all devices
    environment.systemPackages = with pkgs; [ git vim wget curl ];

    # Use the system-level nixpkgs instead of Home Manager's
    home-manager.useGlobalPkgs = true;

    # Install packages to /etc/profiles instead of ~/.nix-profile, useful when
    # using multiple profiles for one user
    home-manager.useUserPackages = true;

    # Allow specified unfree packages (identified elsewhere)
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) config.unfreePackages;

    # Set a variable for dotfiles repo, not necessary but convenient
    home-manager.users.${config.user} = {
      home.sessionVariables = { DOTS = config.dotfilesPath; };
    };

  };

}
