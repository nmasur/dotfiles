# SSHD service for allowing SSH access to my machines.

{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.services.openssh;
in
{

  options.nmasur.presets.services.openssh = {
    enable = lib.mkEnableOption "OpenSSH remote access service";
    publicKeys = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf lib.types.str);
      description = "Public SSH keys authorized for this system.";
      default = null;
    };
    # permitRootLogin = lib.mkOption {
    #   type = lib.types.str;
    #   description = "Root login settings.";
    #   default = "no";
    # };
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = [ 22 ];
      allowSFTP = true;
      settings = {
        GatewayPorts = "no";
        X11Forwarding = false;
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    users.users.${config.user}.openssh.authorizedKeys.keys = lib.mkIf (
      cfg.publicKeys != null
    ) cfg.publicKeys;

    # Add terminfo for SSH from popular terminal emulators
    environment.enableAllTerminfo = true;
  };
}
