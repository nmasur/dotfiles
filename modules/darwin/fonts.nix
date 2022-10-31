{ config, pkgs, ... }: {

  home-manager.users.${config.user} = {

    home.packages = with pkgs;
      [ (nerdfonts.override { fonts = [ "FiraCode" ]; }) ];

    programs.alacritty.settings = {
      font.normal.family = "FiraCode Nerd Font Mono";
    };

    programs.kitty.font = {
      package = pkgs.nerdfonts;
      name = "FiraCode";
    };

  };

}
