{ config, pkgs, lib, ... }: {

  config = {

    services.netdata = {
      enable = true;

      # Disable local dashboard (unsecured)
      config = { web.mode = "none"; };
    };

  };

}
