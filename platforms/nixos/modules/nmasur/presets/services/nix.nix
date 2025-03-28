{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.nmasur.settings) username;
  cfg = config.nmasur.presets.services.nix;
in

{

  options.nmasur.presets.services.nix.enable = lib.mkEnableOption "Nix settings and presets";

  config = lib.mkIf cfg.enable {

    nix = {

      # Set channel to flake packages, used for nix-shell commands
      nixPath = [ "nixpkgs=${pkgs.path}" ];

      # For security, only allow specific users
      settings.allowed-users = [
        "@wheel" # Anyone in the wheel group
        username # The current user
      ];

      # Enable features in Nix commands
      extraOptions = ''
        experimental-features = nix-command flakes
        warn-dirty = false
      '';

      # Set automatic generation cleanup for home-manager
      gc = {
        automatic = true;
        options = "--delete-older-than 10d";
      };

      settings = {

        # Trust users for messing with Nix stuff
        trusted-users = [
          "root"
          "@wheel"
          username
        ];

        # Add community Cachix to binary cache
        # Don't use at work because blocked by corporate firewall
        builders-use-substitutes = true;
        substituters = [
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];

        auto-optimise-store = true;
      };

    };

  };

}
