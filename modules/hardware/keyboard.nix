{ ... }: {

  services.xserver = {
    # Keyboard responsiveness
    autoRepeatDelay = 250;
    autoRepeatInterval = 40;

    # Configure keymap in X11
    layout = "us";
    xkbOptions = "eurosign:e,caps:swapescape";
  };

}
