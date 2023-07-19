{ config, pkgs, lib, ... }:

let

  neovim = import ./package {
    inherit pkgs;
    colors = config.theme.colors;
  };

in {

  options.neovim.enable = lib.mkEnableOption "Neovim.";

  config = lib.mkIf config.neovim.enable {
    home-manager.users.${config.user} =

      {

        home.packages = [ neovim ];

        programs.git.extraConfig.core.editor = "nvim";
        home.sessionVariables = {
          EDITOR = "nvim";
          MANPAGER = "nvim +Man!";
        };
        programs.fish = {
          shellAliases = { vim = "nvim"; };
          shellAbbrs = {
            v = lib.mkForce "nvim";
            vl = lib.mkForce "nvim -c 'normal! `0' -c 'bdelete 1'";
            vll = "nvim -c 'Telescope oldfiles'";
          };
        };
        programs.kitty.settings.scrollback_pager = ''
          $SHELL -c 'sed -r "s/[[:cntrl:]]\]133;[AC]..//g" | ${neovim}/bin/nvim -c "setlocal nonumber norelativenumber nolist laststatus=0" -c "lua baleia = require(\"baleia\").setup({}); baleia.once(0)" -c "map <silent> q :qa!<CR>" -c "autocmd VimEnter * normal G"' '';

        xdg.desktopEntries.nvim = lib.mkIf pkgs.stdenv.isLinux {
          name = "Neovim wrapper";
          exec = "kitty nvim %F";
        };
        xdg.mimeApps.defaultApplications = lib.mkIf pkgs.stdenv.isLinux {
          "text/plain" = [ "nvim.desktop" ];
          "text/markdown" = [ "nvim.desktop" ];
        };

      };

    # # Used for icons in Vim
    # fonts.fonts = with pkgs; [ nerdfonts ];

  };

}
