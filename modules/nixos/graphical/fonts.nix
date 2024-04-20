{
  config,
  pkgs,
  lib,
  ...
}:

let
  fontName = "Victor Mono";
in
{

  config = lib.mkIf (config.gui.enable && pkgs.stdenv.isLinux) {

    fonts.packages = with pkgs; [
      victor-mono # Used for Vim and Terminal
      (nerdfonts.override { fonts = [ "Hack" ]; }) # For Polybar, Rofi
    ];
    fonts.fontconfig.defaultFonts.monospace = [ fontName ];

    home-manager.users.${config.user} = {
      xsession.windowManager.i3.config.fonts = {
        names = [ "pango:${fontName}" ];
        # style = "Regular";
        # size = 11.0;
      };
      services.polybar.config."bar/main".font-0 = "Hack Nerd Font:size=10;2";
      programs.rofi.font = "Hack Nerd Font 14";
      programs.alacritty.settings.font.normal.family = fontName;
      programs.kitty.font.name = fontName;
      services.dunst.settings.global.font = "Hack Nerd Font 14";
    };
  };
}
