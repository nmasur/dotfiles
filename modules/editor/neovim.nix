{ config, pkgs, ... }: {

  home.packages = with pkgs; [
    neovim
    gcc # for tree-sitter
  ];

  xdg.configFile = { "nvim/init.lua".source = ../../nvim.configlink/init.lua; };

  programs.git.extraConfig.core.editor = "nvim";

}
