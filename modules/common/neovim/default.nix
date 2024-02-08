{ config, pkgs, lib, ... }:

let

  neovim = import ./package {
    inherit pkgs;
    colors = config.theme.colors;
    c = config.c.enable;
    github = true;
    kubernetes = config.kubernetes.enable;
    python = config.python.enable;
    terraform = config.terraform.enable;
  };

in {

  options.neovim.enable = lib.mkEnableOption "Neovim.";

  config = lib.mkIf config.neovim.enable {
    home-manager.users.${config.user} =

      {

        home.packages = [ neovim ];

        # Use Neovim as the editor for git commit messages
        programs.git.extraConfig.core.editor = "nvim";
        programs.jujutsu.settings.ui.editor = "nvim";

        # Set Neovim as the default app for text editing and manual pages
        home.sessionVariables = {
          EDITOR = "nvim";
          MANPAGER = "nvim +Man!";
        };

        # Create quick aliases for launching Neovim
        programs.fish = {
          shellAliases = { vim = "nvim"; };
          shellAbbrs = {
            v = lib.mkForce "nvim";
            vl = lib.mkForce "nvim -c 'normal! `0' -c 'bdelete 1'";
            vll = "nvim -c 'Telescope oldfiles'";
          };
        };

        # Set Neovim as the kitty terminal "scrollback" (vi mode) option.
        # Requires removing some of the ANSI escape codes that are sent to the
        # scrollback using sed and baleia, as well as removing several
        # unnecessary features.
        programs.kitty.settings.scrollback_pager =
          "${neovim}/bin/nvim --headless +'KittyScrollbackGenerateKittens' +'set nonumber' +'set norelativenumber' +'%print' +'quit!' 2>&1";

        # Create a desktop option for launching Neovim from a file manager
        # (Requires launching the terminal and then executing Neovim)
        xdg.desktopEntries.nvim = lib.mkIf pkgs.stdenv.isLinux {
          name = "Neovim wrapper";
          exec = "kitty nvim %F";
          mimeType = [ "text/plain" "text/markdown" ];
        };
        xdg.mimeApps.defaultApplications = lib.mkIf pkgs.stdenv.isLinux {
          "text/plain" = [ "nvim.desktop" ];
          "text/markdown" = [ "nvim.desktop" ];
        };

      };

  };

}
