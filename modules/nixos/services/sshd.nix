# SSHD service for allowing SSH access to my machines.

{
  config,
  pkgs,
  lib,
  ...
}:
{

  options = {
    publicKeys = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf lib.types.str);
      description = "Public SSH key authorized for this system.";
      default = null;
    };
    permitRootLogin = lib.mkOption {
      type = lib.types.str;
      description = "Root login settings.";
      default = "no";
    };
  };

  config = lib.mkIf config.services.openssh.enable {
    services.openssh = {
      ports = [ 22 ];
      allowSFTP = true;
      settings = {
        GatewayPorts = "no";
        X11Forwarding = false;
        PasswordAuthentication = false;
        PermitRootLogin = lib.mkDefault config.permitRootLogin;
      };
    };

    users.users.${config.user}.openssh.authorizedKeys.keys = lib.mkIf (
      config.publicKeys != null
    ) config.publicKeys;

    # Implement a simple fail2ban service for sshd
    services.sshguard.enable = true;

    # Add terminfo for SSH from popular terminal emulators
    # Fix: terminfo now installs contour, which is broken on ARM
    # - https://github.com/NixOS/nixpkgs/pull/253334
    # - Will disable until fixed
    environment.enableAllTerminfo = pkgs.stdenv.isLinux && pkgs.stdenv.isx86_64;
  };
}
