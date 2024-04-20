{
  config,
  pkgs,
  lib,
  ...
}:
{

  # MacOS-specific settings for Kitty
  home-manager.users.${config.user} = lib.mkIf pkgs.stdenv.isDarwin {
    programs.kitty = {
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
