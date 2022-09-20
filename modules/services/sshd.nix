{ config, pkgs, lib, ... }: {

  options = {
    publicKey = lib.mkOption {
      type = lib.types.str;
      description = "Public SSH key authorized for this system.";
    };
    permitRootLogin = lib.mkOption {
      type = lib.types.str;
      description = "Root login settings.";
      default = "no";
    };
  };

  config = {
    services.openssh = {
      enable = true;
      ports = [ 22 ];
      passwordAuthentication = false;
      gatewayPorts = "no";
      forwardX11 = false;
      allowSFTP = true;
      permitRootLogin = config.permitRootLogin;
    };

    users.users.${config.user}.openssh.authorizedKeys.keys =
      [ config.publicKey ];
  };

}
