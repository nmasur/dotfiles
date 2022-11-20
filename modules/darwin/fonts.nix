{ config, pkgs, ... }: {

  home-manager.users.${config.user} = {

    home.packages = with pkgs;
      [ (nerdfonts.override { fonts = [ "VictorMono" ]; }) ];

    programs.alacritty.settings = { font.normal.family = "VictorMono"; };

    programs.kitty.font = {
      package = (pkgs.nerdfonts.override { fonts = [ "VictorMono" ]; });
      name = "VictorMono Nerd Font Mono";
    };

  };

}
