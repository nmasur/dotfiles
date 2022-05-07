{ config, pkgs, lib, ... }: {

  home-manager.users.${config.user} = {

    home.packages = with pkgs; [
      neovim
      gcc # for tree-sitter
    ];

    xdg.configFile = {
      "nvim/init.lua".text = lib.mkMerge [
        (lib.mkOrder 100 ''
          ${builtins.readFile ./packer.lua}
          ${builtins.readFile ./settings.lua}
          ${builtins.readFile ./functions.lua}
          ${builtins.readFile ./keybinds.lua}
        '')
      ];
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
