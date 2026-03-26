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

      # Maple Mono NF (Ligature unhinted)
      pkgs.maple-mono.NF-unhinted
    ];
    fonts.fontconfig = {
      enable = true;
      defaultFonts.monospace = [ "Maple Mono NF" ];
    };

    xsession.windowManager.i3.config.fonts = {
      # names = [ "pango:Victor Mono" ];
      names = [ "pango:Maple Mono" ];
      # style = "Regular";
      # size = 11.0;
    };
    services.polybar.config."bar/main".font-0 = "Hack Nerd Font:size=10;2";
    programs.rofi.font = "Hack Nerd Font 14";
    programs.alacritty.settings.font.normal.family = "Maple Mono NF";
    programs.kitty.font.name = "Maple Mono NF";
    nmasur.presets.programs.wezterm.font = "Maple Mono NF";
    programs.ghostty.settings.font-family = "Maple Mono NF";
    services.dunst.settings.global.font = "Hack Nerd Font 14";
  };
}
