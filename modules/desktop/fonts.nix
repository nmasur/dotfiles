{ config, pkgs, lib, ... }:

let fontName = "Victor Mono";

in {

  config = lib.mkIf config.gui.enable {

    fonts.fonts = with pkgs;
      [
        pkgs.victor-mono # Used for Vim and Terminal
      ];
    fonts.fontconfig.defaultFonts.monospace = [ fontName ];

    home-manager.users.${config.user} = {
      xsession.windowManager.i3.config.fonts = {
        names = [ "pango:${fontName}" ];
        # style = "Regular";
        # size = 11.0;
      };
      programs.rofi.font = "${fontName} 14";
    };

  };

}
