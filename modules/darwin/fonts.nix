{
  config,
  pkgs,
  lib,
  ...
}:
{

  home-manager.users.${config.user} = lib.mkIf pkgs.stdenv.isDarwin {

    home.packages = with pkgs; [ (nerdfonts.override { fonts = [ "VictorMono" ]; }) ];

    programs.alacritty.settings = {
      font.normal.family = "VictorMono";
    };

    programs.kitty.font = {
      package = pkgs.nerd-fonts.victor-mono;
      name = "VictorMono Nerd Font Mono";
    };
  };
}
