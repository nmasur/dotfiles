{ config, pkgs, lib, ... }: {

  home-manager.users.${config.user} = {

    home.packages = [
      (import ./package {
        inherit pkgs;
        colors = import config.theme.colors.neovimConfig { inherit pkgs; };
      })
    ];

    programs.git.extraConfig.core.editor = "nvim";
    home.sessionVariables = {
      EDITOR = "nvim";
      MANPAGER = "nvim +Man!";
    };
    programs.fish = {
      shellAliases = { vim = "nvim"; };
      shellAbbrs = {
        v = lib.mkForce "nvim";
        vl = lib.mkForce "vim -c 'normal! `0' -c 'bdelete 1'";
        vll = "nvim -c 'Telescope oldfiles'";
      };
    };

  };

  # # Used for icons in Vim
  # fonts.fonts = with pkgs; [ nerdfonts ];

}
