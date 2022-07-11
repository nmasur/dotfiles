{ config, pkgs, lib, ... }: {

  home-manager.users.${config.user} = {

    home.packages = with pkgs; [
      neovim
      gcc # for tree-sitter
      shfmt # used everywhere
      shellcheck # used everywhere
    ];

    xdg.configFile = {
      "nvim/init.lua".source = ./init.lua;
      "nvim/lua" = {
        source = ./lua;
        recursive = true; # Allows adding more files
      };
      "nvim/lua/packer/colors.lua".text = config.gui.colorscheme.neovimConfig;
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

    # Always run packer.nvim sync
    home.activation.nvimPackerSync =
      config.home-manager.users.${config.user}.lib.dag.entryAfter
      [ "onFilesChange" ] ''
        $DRY_RUN_CMD nvim +PackerSync +qa
      '';

  };

  # Used for icons in Vim
  fonts.fonts = with pkgs; [ nerdfonts ];

}
