{
  config,
  pkgs,
  lib,
  ...
}:
{

  imports = [
    ./auto-upgrade.nix
    ./doas.nix
    ./journald.nix
    ./user.nix
    ./timezone.nix
  ];

  config = lib.mkIf pkgs.stdenv.isLinux {

    # Pin a state version to prevent warnings
    system.stateVersion = config.home-manager.users.${config.user}.home.stateVersion;
  };
}
