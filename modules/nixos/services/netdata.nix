{ config, lib, ... }: {

  options.netdata.enable = lib.mkEnableOption "Netdata metrics.";

  config = lib.mkIf config.netdata.enable {

    services.netdata = {
      enable = true;

      # Disable local dashboard (unsecured)
      config = { web.mode = "none"; };
    };

  };

}
