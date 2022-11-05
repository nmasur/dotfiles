{ config, pkgs, lib, ... }: {

  home-manager.users.${config.user} = {

    home.packages = with pkgs; [
      neovim
      gcc # for tree-sitter
      tree-sitter # for tree-sitter-gitignore parser
      nodejs # for tree-sitter-gitignore parser
      shfmt # used everywhere
      shellcheck # used everywhere
    ];

    xdg.configFile = {
      "nvim/init.lua".source = ./init.lua;
      "nvim/lua" = {
        source = ./lua;
        recursive = true; # Allows adding more files
      };
      "nvim/lua/packer/colors.lua".source = config.theme.colors.neovimConfig;
      "nvim/lua/background.lua".text = ''
        vim.o.background = "${
          if config.theme.dark == true then "dark" else "light"
        }"
      '';
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
        vl = lib.mkForce "vim -c 'normal! `0' -c 'bdelete 1'";
        vll = "nvim -c 'Telescope oldfiles'";
      };
    };

    # Always run packer.nvim sync
    home.activation.nvimPackerSync =
      config.home-manager.users.${config.user}.lib.dag.entryAfter
      [ "writeBoundary" ] ''
        $DRY_RUN_CMD ${pkgs.neovim}/bin/nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
      '';

  };

  # Used for icons in Vim
  fonts.fonts = with pkgs; [ nerdfonts ];

}
