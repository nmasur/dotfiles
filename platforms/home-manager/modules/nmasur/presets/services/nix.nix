{
  config,
  pkgs,
  lib,
  ...
}:

let
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
        config.home.username # The current user
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

        # Add community Cachix to binary cache
        # Don't use at work because blocked by corporate firewall
        builders-use-substitutes = true;
        substituters = lib.mkIf (!config.nmasur.profiles.work.enable) [
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = lib.mkIf (!config.nmasur.profiles.work.enable) [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];

        # Scans and hard links identical files in the store
        # Not working with macOS: https://github.com/NixOS/nix/issues/7273
        auto-optimise-store = lib.mkIf (!pkgs.stdenv.isDarwin) true;
      };

    };

  };

}
