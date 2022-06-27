{ config, ... }: {

  imports = [ ./user.nix ./timezone.nix ./doas.nix ];

  # Pin a state version to prevent warnings
  system.stateVersion = "22.11";
  home-manager.users.${config.user}.home.stateVersion = "22.11";
  home-manager.users.root.home.stateVersion = "22.11";

}
