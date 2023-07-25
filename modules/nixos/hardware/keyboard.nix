{ config, ... }: {

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
          settings = { main = { capslock = "overload(control, esc)"; }; };
        };
      };
    };

    # Enable num lock on login
    home-manager.users.${config.user}.xsession.numlock.enable = true;

  };

}
