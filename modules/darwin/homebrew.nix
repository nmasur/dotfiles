{ config, ... }: {

  # Homebrew - Mac-specific packages that aren't in Nix

  # Requires Homebrew to be installed
  system.activationScripts.preUserActivation.text = ''
    if ! xcode-select --version 2>/dev/null; then
      $DRY_RUN_CMD xcode-select --install
    fi
    if ! /usr/local/bin/brew --version 2>/dev/null; then
      $DRY_RUN_CMD /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
  '';

  homebrew = {
    enable = true;
    autoUpdate = false; # Don't update during rebuild
    cleanup = "zap"; # Uninstall all programs not declared
    taps = [
      "homebrew/cask" # Required for casks
      "homebrew/cask-drivers" # Used for Logitech G-Hub
    ];
    brews = [
      "trash" # Delete files and folders to trash instead of rm
    ];
    casks = [
      "firefox" # Firefox packaging on Nix is broken for MacOS
      "1password" # 1Password packaging on Nix is broken for MacOS
      "scroll-reverser" # Different scroll style for mouse vs. trackpad
      "meetingbar" # Show meetings in menu bar
      "gitify" # Git notifications in menu bar
      "logitech-g-hub" # Mouse and keyboard management
      "mimestream" # Gmail client
      "obsidian" # Obsidian packaging on Nix is not available for MacOS
      "steam" # Not packaged for Nix
    ];
    global.brewfile = true; # Run brew bundle from anywhere
    global.noLock = true; # Don't save lockfile (since running from anywhere)
  };

  home-manager.users.${config.user} = {

    programs.fish.shellAbbrs.t = "trash";

  };

}
