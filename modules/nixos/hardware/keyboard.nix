{ config, ... }: {

  config = {

    services.xserver = {

      layout = "us";

      # Keyboard responsiveness
      autoRepeatDelay = 250;
      autoRepeatInterval = 40;

      # Swap escape key with caps lock key
      xkbOptions = "eurosign:e,caps:swapescape";

    };

    # Enable num lock on login
    home-manager.users.${config.user}.xsession.numlock.enable = true;

  };

}
