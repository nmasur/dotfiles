{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.fonts;
in
{

  options.nmasur.presets.fonts.enable = lib.mkEnableOption "Font configuration";

  config = lib.mkIf cfg.enable {

    home.packages = [
      pkgs.nerd-fonts.victor-mono # Used for Vim and Terminal
      pkgs.nerd-fonts.hack # For Polybar, Rofi
    ];
    fonts.fontconfig = {
      enable = true;
      defaultFonts.monospace = [ "Victor Mono" ];
    };

    xsession.windowManager.i3.config.fonts = {
      names = [ "pango:Victor Mono" ];
      # style = "Regular";
      # size = 11.0;
    };
    services.polybar.config."bar/main".font-0 = "Hack Nerd Font:size=10;2";
    programs.rofi.font = "Hack Nerd Font 14";
    programs.alacritty.settings.font.normal.family = "VictorMono";
    programs.kitty.font.name = "VictorMono Nerd Font Mono";
    nmasur.presets.programs.wezterm.font = "VictorMono Nerd Font Mono";
    services.dunst.settings.global.font = "Hack Nerd Font 14";
  };
}
