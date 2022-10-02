{ config, pkgs, lib, ... }:

let

  libraryPath = "/var/lib/calibre-server";

in {

  options = { };

  config = {
    services.calibre-server = {
      enable = true;
      libraries = [ libraryPath ];
    };

    services.calibre-web = {
      enable = true;
      openFirewall = true;
      options = {
        reverseProxyAuth.enable = false;
        enableBookConversion = true;
      };
    };

  };

}
