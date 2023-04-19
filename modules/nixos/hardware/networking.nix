{ config, lib, ... }: {

  config = lib.mkIf config.physical {

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    networking.useDHCP = false;
    networking.interfaces.enp5s0.useDHCP = true;
    networking.interfaces.wlp4s0.useDHCP = true;

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
