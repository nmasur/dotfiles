{ config, pkgs, ... }: {

  config = {

    services.xserver = {

      layout = "us";

      # Keyboard responsiveness
      autoRepeatDelay = 250;
      autoRepeatInterval = 40;

    };

    # Use capslock as escape and/or control
    services.keyd = {
      enable = true;
      keyboards = {
        default = {
          ids = [ "*" ];
          settings = {
            main = { capslock = "overload(control, esc)"; };

            # Fix: ctrl-click sends escape afterwards
            # Suppresses escape if held for more than 500ms
            # https://github.com/rvaiya/keyd/issues/424
            global = { overload_tap_timeout = 500; };
          };
        };
      };
    };

    # For some reason, keyd doesn't restart properly when updating
    system.activationScripts.keyd.text =
      "${pkgs.systemd}/bin/systemctl restart keyd.service";

    # Enable num lock on login
    home-manager.users.${config.user}.xsession.numlock.enable = true;

  };

}
