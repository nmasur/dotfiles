{ ... }: {

  imports = [ ./user.nix ./timezone.nix ./doas.nix ];

  # Pin a state version to prevent warnings
  system.stateVersion = "22.11";

}
