{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.kitty-darwin;
in
{

  options.nmasur.presets.programs.kitty-darwin.enable = lib.mkEnableOption "Kitty terminal for macOS";

  # MacOS-specific settings for Kitty
  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      font.size = lib.mkForce 20;
      settings = {
        shell = "/run/current-system/sw/bin/fish";
        macos_traditional_fullscreen = true;
        macos_quit_when_last_window_closed = true;
        disable_ligatures = "always";
        macos_option_as_alt = true;
      };
    };
  };
}
