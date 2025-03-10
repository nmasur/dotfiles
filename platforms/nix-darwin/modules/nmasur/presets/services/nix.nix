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

        # Scans and hard links identical files in the store
        # Not working with macOS: https://github.com/NixOS/nix/issues/7273
        auto-optimise-store = false;
      };

    };

  };

}
