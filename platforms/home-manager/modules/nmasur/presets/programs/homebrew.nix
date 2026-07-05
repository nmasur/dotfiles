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

    home.file.".Brewfile".text = /* homebrew */ ''
      # Taps
      # tap "homebrew/bundle"

      # Brews (CLI Apps)
      brew "trash" # Delete files and folders to trash instead of rm

      # Casks (GUI Apps)
      cask "scroll-reverser" # Different scroll style for mouse vs. trackpad
      cask "notunes" # Don't launch Apple Music with the play button
      cask "topnotch" # Darkens the menu bar to complete black
      cask "ghostty" # Terminal application (not buildable on Nix on macOS)

      # Mac App Store apps (requires 'mas' CLI, optional)
      # mas "Tailscale", id: 1475387142
    '';

    # Add homebrew paths to CLI path
    home.sessionPath = [
      "/opt/homebrew/bin/"
      "/opt/homebrew/opt/trash/bin"
    ];

    programs.fish.shellAbbrs.t = "trash";

    home.activation.backendBrewBundle = /* bash */ ''
      # Requires Homebrew to be installed
      if ! /usr/bin/xcode-select --version 2>/dev/null; then
        $DRY_RUN_CMD /usr/bin/xcode-select --install
      fi
      if ! /opt/homebrew/bin/brew --version 2>/dev/null; then
        $DRY_RUN_CMD /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi

      verboseEcho "Syncing Homebrew dependencies via Brewfile..."

      # Ensure Homebrew is in the PATH for the script (Apple Silicon path)
      export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

      # Keep activation deterministic and non-interactive. Without this, brew
      # auto-updates (git-fetches its taps) which can hang forever when there
      # is no TTY (network stall, credential prompt, or a leftover brew lock).
      export HOMEBREW_NO_AUTO_UPDATE=1
      export HOMEBREW_NO_ENV_HINTS=1

      # Point brew at the generated Brewfile in the Nix store directly. This
      # avoids depending on the ~/.Brewfile symlink being linked first, and
      # sidesteps the --global vs. inherited HOMEBREW_BUNDLE_FILE conflict.
      unset HOMEBREW_BUNDLE_FILE
      brewfile="${config.home.file.".Brewfile".source}"

      if command -v brew &> /dev/null; then
        # Install/upgrade everything declared in the Brewfile...
        $DRY_RUN_CMD brew bundle install --file="$brewfile"
        # ...then uninstall anything NOT listed (replaces deprecated --cleanup).
        $DRY_RUN_CMD brew bundle cleanup --file="$brewfile" --force
      else
        verboseEcho "Warning: Homebrew not found. Actions skipped."
      fi


    '';

  };
}
