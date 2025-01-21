{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.profiles.work;
in

{

  options.nmasur.profiles.work.enable = lib.mkEnableOption "work machine";

  config = lib.mkIf cfg.enable {
    homebrew.casks = [
      "1password" # 1Password will not launch from Nix on macOS
      # "gitify" # Git notifications in menu bar (downgrade manually from 4.6.1)
      # "logitech-g-hub" # Mouse and keyboard management
      "logitune" # Logitech webcam firmware
      "meetingbar" # Show meetings in menu bar
    ];
  };
}
