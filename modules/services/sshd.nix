{ config, pkgs, lib, ... }: {

  options = {
    publicKey = lib.mkOption {
      type = lib.types.str;
      description = "Public SSH key authorized for this system.";
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
      permitRootLogin = "no";
    };

    users.users.${config.user}.authorizedKeys.keys = [ config.publicKey ];
  };

}
