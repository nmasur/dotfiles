{ ... }: {

  homebrew = {
    enable = true;
    autoUpdate = false; # Don't update during rebuild
    cleanup = "zap"; # Uninstall all programs not declared
    taps = [
      "homebrew/cask-drivers" # Used for Logitech G-Hub
    ];
    brews = [
      "trash" # Delete files and folders to trash instead of rm
    ];
    casks = [
      "scroll-reverser" # Different scroll style for mouse vs. trackpad
      "meetingbar" # Show meetings in menu bar
      "gitify" # Git notifications in menu bar
      "logitech-g-hub" # Mouse and keyboard management
    ];
    global.brewfile = true; # Run brew bundle from anywhere
    global.nolock = true; # Don't save lockfile (since running from anywhere)
  };

}
