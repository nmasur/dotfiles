{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.profiles.base;
in

{

  options.nmasur.profiles.base.enable = lib.mkEnableOption "base macOS config";

  config = lib.mkIf cfg.enable {

    nmasur.presets = {
      fish = lib.mkDefault true;
      homebrew = lib.mkDefault true;
    };

    homebrew.brews = lib.mkDefault [
      "trash" # Delete files and folders to trash instead of rm
    ];
    homebrew.casks = lib.mkDefault [
      "scroll-reverser" # Different scroll style for mouse vs. trackpad
      "notunes" # Don't launch Apple Music with the play button
    ];

    # Add homebrew paths to CLI path
    home.sessionPath = [
      "/opt/homebrew/opt/trash/bin"
    ];

    # Include home-manager config in nix-darwin
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
