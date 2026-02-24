{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.homebrew;
in

{

  options.nmasur.presets.programs.homebrew.enable =
    lib.mkEnableOption "Homebrew macOS package manager";

  config = lib.mkIf cfg.enable {
    # Requires Homebrew to be installed
    system.activationScripts.preActivation.text = ''
      if ! xcode-select --version 2>/dev/null; then
        $DRY_RUN_CMD xcode-select --install
      fi
      if ! /opt/homebrew/bin/brew --version 2>/dev/null; then
        $DRY_RUN_CMD /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
    '';

    homebrew = {
      enable = true;
      onActivation = {
        autoUpdate = false; # Don't update during rebuild
        cleanup = "zap"; # Uninstall all programs not declared
        upgrade = true;
      };
      global = {
        brewfile = true; # Run brew bundle from anywhere
      };
    };

  };
}
