{
  config,
  pkgs,
  lib,
  ...
}:
{

  # Homebrew - Mac-specific packages that aren't in Nix
  config = lib.mkIf pkgs.stdenv.isDarwin {

    # Requires Homebrew to be installed
    system.activationScripts.preUserActivation.text = ''
      if ! xcode-select --version 2>/dev/null; then
        $DRY_RUN_CMD xcode-select --install
      fi
      if ! /opt/homebrew/bin/brew --version 2>/dev/null; then
        $DRY_RUN_CMD /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
    '';

    # Add homebrew paths to CLI path
    home-manager.users.${config.user}.home.sessionPath = [ "/opt/homebrew/bin/" ];

    homebrew = {
      enable = true;
      onActivation = {
        autoUpdate = false; # Don't update during rebuild
        cleanup = "zap"; # Uninstall all programs not declared
        upgrade = true;
      };
      global = {
        brewfile = true; # Run brew bundle from anywhere
        lockfiles = false; # Don't save lockfile (since running from anywhere)
      };
      brews = [
        "trash" # Delete files and folders to trash instead of rm
      ];
      casks = [
        "1password" # 1Password will not launch from Nix on macOS
        # "gitify" # Git notifications in menu bar (downgrade manually from 4.6.1)
        "keybase" # GUI on Nix not available for macOS
        # "logitech-g-hub" # Mouse and keyboard management
        "logitune" # Logitech webcam firmware
        "meetingbar" # Show meetings in menu bar
        "scroll-reverser" # Different scroll style for mouse vs. trackpad
        "notunes" # Don't launch Apple Music with the play button
        "steam" # Not packaged for Nixon macOS
        # "epic-games" # Not packaged for Nix
      ];
    };
  };
}
