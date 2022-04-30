{ pkgs, user, ... }: {

  home-manager.users.${user} = {

    home.packages = with pkgs; [
      neovim
      gcc # for tree-sitter
    ];

    xdg.configFile = {
      "nvim/init.lua".source = ../../nvim.configlink/init.lua;
    };

    programs.git.extraConfig.core.editor = "nvim";
    home.sessionVariables = { EDITOR = "nvim"; };
    programs.fish = {
      shellAliases = { vim = "nvim"; };
      shellAbbrs = {
        vll = "vim -c 'Telescope oldfiles'";
        vimrc = "vim ${builtins.toString ../../.}/nvim.configlink/init.lua";
      };
    };

  };

  # Used for icons in Vim
  fonts.fonts = with pkgs; [ nerdfonts ];

}
