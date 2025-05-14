{ lib, hostnames, ... }:

{
  options.nmasur.settings = {
    username = lib.mkOption {
      type = lib.types.str;
      description = "Primary username for the system";
    };
    fullName = lib.mkOption {
      type = lib.types.str;
      description = "Human readable name of the user";
    };
    host = lib.mkOption {
      type = lib.types.str;
      description = "Name of the host of this deployment";
    };
    hostnames = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = "Map of service names to FQDNs";
      default = hostnames;
    };
  };
}
