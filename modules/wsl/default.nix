{
  config,
  pkgs,
  lib,
  ...
}:
{

  config = lib.mkIf (pkgs.stdenv.isLinux && config.wsl.enable) {

    # Systemd doesn't work in WSL so these must be disabled
    services.geoclue2.enable = lib.mkForce false;
    location = {
      provider = lib.mkForce "manual";
    };
    services.localtimed.enable = lib.mkForce false;

    # Used by NeoVim for clipboard sharing with Windows
    # home-manager.users.${config.user}.home.sessionPath =
    #   [ "/mnt/c/Program Files/win32yank/" ];

    # Replace config directory with our repo, since it sources from config on
    # every launch
    system.activationScripts.configDir.text = ''
      rm -rf /etc/nixos
      ln --symbolic --no-dereference --force ${config.dotfilesPath} /etc/nixos
    '';
  };
}
