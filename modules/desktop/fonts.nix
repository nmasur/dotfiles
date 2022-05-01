{ pkgs, lib, gui, ... }: {

  config = lib.mkIf gui.enable {

    fonts.fonts = with pkgs;
      [
        pkgs."${gui.font.package}" # Used for Vim and Terminal
        # siji # More icons for Polybar
      ];
    fonts.fontconfig.defaultFonts.monospace = [ gui.font.name ];

  };

}
