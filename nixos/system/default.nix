{ config, pkgs, lib, ... }: {

  imports = [ ./user.nix ./timezone.nix ./doas.nix ];

  config = lib.mkIf pkgs.stdenv.isLinux {

    # Pin a state version to prevent warnings
    system.stateVersion =
      config.home-manager.users.${config.user}.home.stateVersion;

  };

}