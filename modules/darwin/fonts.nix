{ config, pkgs, ... }: {

  home-manager.users.${config.user} = {

    home.packages = with pkgs;
      [ (nerdfonts.override { fonts = [ "Victor Mono" ]; }) ];

    programs.alacritty.settings = { font.normal.family = "Victor Mono"; };

    programs.kitty.font = {
      package = pkgs.nerdfonts;
      name = "Victor Mono";
    };

  };

}
