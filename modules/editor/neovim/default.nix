{ config, pkgs, lib, ... }: {

  home-manager.users.${config.user} = {

    home.packages = with pkgs; [
      neovim
      gcc # for tree-sitter
      shfmt # used everywhere
      shellcheck # used everywhere
    ];

    xdg.configFile = {
      "nvim/init.lua".text = lib.mkMerge [
        (lib.mkOrder 100 ''
          ${builtins.readFile ./bootstrap.lua}
          require("packer").startup(function(use)
          ${builtins.readFile ./packer-basics.lua}
        '')
        (lib.mkOrder 200 ''
          ${builtins.readFile ./colors.lua}
        '')
        (lib.mkOrder 300 ''
          ${builtins.readFile ./lsp.lua}
        '')
        (lib.mkOrder 400 ''
          ${builtins.readFile ./completion.lua}
        '')
        (lib.mkOrder 500 ''
          ${builtins.readFile ./syntax.lua}
        '')
        (lib.mkOrder 600 ''
          ${builtins.readFile ./telescope.lua}
        '')
        (lib.mkOrder 700 ''
          ${builtins.readFile ./packer-sync.lua}
          end)
        '')
        (lib.mkOrder 800 ''
          ${builtins.readFile ./settings.lua}
          ${builtins.readFile ./functions.lua}
          ${builtins.readFile ./keybinds.lua}
        '')
      ];
    };

    programs.git.extraConfig.core.editor = "nvim";
    home.sessionVariables = {
      EDITOR = "nvim";
      MANPAGER = "nvim +Man!";
    };
    programs.fish = {
      shellAliases = { vim = "nvim"; };
      shellAbbrs = {
        v = lib.mkForce "nvim";
        vl = lib.mkForce "nvim -c 'normal! `0'";
        vll = "nvim -c 'Telescope oldfiles'";
      };
    };

  };

  # Used for icons in Vim
  fonts.fonts = with pkgs; [ nerdfonts ];

}
