{ config, pkgs, lib, ... }: {

  config = lib.mkIf config.gui.enable {

    fonts.fonts = with pkgs;
      [
        pkgs.victor-mono # Used for Vim and Terminal
      ];
    fonts.fontconfig.defaultFonts.monospace = [ "Victor Mono" ];

  };

}
