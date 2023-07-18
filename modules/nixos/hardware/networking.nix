{ config, lib, ... }: {

  config = lib.mkIf config.physical {

    networking.useDHCP = true;

    networking.firewall.allowPing = lib.mkIf config.server true;

    # DNS service discovery
    services.avahi = {
      enable = true;
      domainName = "local";
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        workstation = true;
      };
    };

    # Resolve local hostnames using Avahi DNS
    services.avahi.nssmdns = true;

  };

}
