{ config, ... }: {

  imports = [ ./user.nix ./timezone.nix ./doas.nix ];

  # Pin a state version to prevent warnings
  system.stateVersion =
    config.home-manager.users.${config.user}.home.stateVersion;

}
