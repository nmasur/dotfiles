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

  };

}
