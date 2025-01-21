{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.services.avahi;
in

{

  options.nmasur.presets.services.avahi.enable = lib.mkEnableOption "Avahi DNS service discovery";

  config = lib.mkIf cfg.enable {

    # DNS service discovery
    services.avahi = {
      enable = true;
      domainName = "local";
      ipv6 = false; # Should work either way
      # Resolve local hostnames using Avahi DNS
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        workstation = true;
      };
    };

  };
}
