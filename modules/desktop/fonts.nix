{ pkgs, font, ... }: {

  fonts.fonts = with pkgs; [
    font.package # Used for Vim and Terminal
    font-awesome # Icons for i3
    # siji # More icons for Polybar
  ];
  fonts.fontconfig.defaultFonts.monospace = [ font.name ];

}
