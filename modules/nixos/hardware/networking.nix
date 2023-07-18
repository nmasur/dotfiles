{ config, lib, ... }: {

  config = lib.mkIf config.physical {

    networking.useDHCP = true;

    networking.firewall.allowPing = lib.mkIf config.server true;

    # DNS service discovery
    services.avahi = {
      enable = true;
      domainName = "local";
      ipv6 = false; # Should work either way
      # Resolve local hostnames using Avahi DNS
      nssmdns = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        workstation = true;
      };
    };
  };

}
