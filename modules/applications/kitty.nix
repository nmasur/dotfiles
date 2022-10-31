{ config, pkgs, lib, ... }: {

  config = lib.mkIf config.gui.enable {
    home-manager.users.${config.user} = {
      # xsession.windowManager.i3.config.terminal = "kitty";
      # programs.rofi.terminal = "${pkgs.kitty}/bin/kitty";
      programs.kitty = {
        enable = true;
        darwinLaunchOptions = null;
        environment = { };
        extraConfig = "";
        font.size = 14;
        keybindings = { };
        settings = {

          # Colors (adapted from: https://github.com/kdrag0n/base16-kitty/blob/master/templates/default-256.mustache)
          background = config.colorscheme.base00;
          foreground = config.colorscheme.base05;
          selection_background = config.colorscheme.base05;
          selection_foreground = config.colorscheme.base00;
          url_color = config.colorscheme.base04;
          cursor = config.colorscheme.base05;
          active_border_color = config.colorscheme.base03;
          inactive_border_color = config.colorscheme.base01;
          active_tab_background = config.colorscheme.base00;
          active_tab_foreground = config.colorscheme.base05;
          inactive_tab_background = config.colorscheme.base01;
          inactive_tab_foreground = config.colorscheme.base04;
          tab_bar_background = config.colorscheme.base01;

          # normal
          color0 = config.colorscheme.base00;
          color1 = config.colorscheme.base08;
          color2 = config.colorscheme.base0B;
          color3 = config.colorscheme.base0A;
          color4 = config.colorscheme.base0D;
          color5 = config.colorscheme.base0E;
          color6 = config.colorscheme.base0C;
          color7 = config.colorscheme.base05;

          # bright
          color8 = config.colorscheme.base03;
          color9 = config.colorscheme.base08;
          color10 = config.colorscheme.base0B;
          color11 = config.colorscheme.base0A;
          color12 = config.colorscheme.base0D;
          color13 = config.colorscheme.base0E;
          color14 = config.colorscheme.base0C;
          color15 = config.colorscheme.base07;

          # extended base16 colors
          color16 = config.colorscheme.base09;
          color17 = config.colorscheme.base0F;
          color18 = config.colorscheme.base01;
          color19 = config.colorscheme.base02;
          color20 = config.colorscheme.base04;
          color21 = config.colorscheme.base06;

          # Scrollback
          scrolling_lines = 10000;
          scrollback_pager_history_size = 10; # MB
          scrollback_pager = ''
            ${pkgs.neovim}/bin/nvim -c 'setlocal nonumber nolist showtabline=0 foldcolumn=0|Man!' -c "autocmd VimEnter * normal G" -'';

          # Window
          window_padding_width = 4;

          tab_bar_edge = "top";
          tab_bar_style = "slant";

          # macos_traditional_fullscreen = true;
        };
      };
    };
  };
}
