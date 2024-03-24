{ config, pkgs, lib, ... }: {

  config = lib.mkIf config.physical {

    services.xserver = {

      xkb.layout = "us";

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
          settings = { main = { capslock = "overload(control, esc)"; }; };
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
