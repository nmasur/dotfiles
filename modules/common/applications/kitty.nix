{
  config,
  pkgs,
  lib,
  ...
}:
{

  options = {
    kitty = {
      enable = lib.mkEnableOption {
        description = "Enable Kitty.";
        default = false;
      };
    };
  };

  config = lib.mkIf (config.gui.enable && config.kitty.enable) {

    # Set the Rofi-Systemd terminal for viewing logs
    # Using optionalAttrs because only available in NixOS
    environment =
      { }
      // lib.attrsets.optionalAttrs (builtins.hasAttr "sessionVariables" config.environment) {
        sessionVariables.ROFI_SYSTEMD_TERM = "${pkgs.kitty}/bin/kitty";
      };

    home-manager.users.${config.user} = {

      # Set the i3 terminal
      xsession.windowManager.i3.config.terminal = lib.mkIf pkgs.stdenv.isLinux "kitty";

      # Set the Rofi terminal for running programs
      programs.rofi.terminal = lib.mkIf pkgs.stdenv.isLinux "${pkgs.kitty}/bin/kitty";

      # Display images in the terminal
      programs.fish.shellAliases = {
        icat = "kitty +kitten icat";
        ssh = "kitty +kitten ssh";
      };

      programs.kitty = {
        enable = true;
        environment = { };
        extraConfig = "";
        font.size = 14;
        keybindings = {
          # Use shift+enter to complete text suggestions in fish
          "shift+enter" = "send_text all \\x1F";

          # Easy fullscreen toggle (for macOS)
          "super+f" = "toggle_fullscreen";

          # Kitty scrollback nvim
          "kitty_mod+h" = "kitty_scrollback_nvim";
          "kitty_mod+g" = "kitty_scrollback_nvim --config ksb_builtin_last_cmd_output";
        };
        settings = {

          # Required for kitty-scrollback.nvim
          allow_remote_control = "socket-only";
          listen_on = "unix:/tmp/kitty";
          action_alias = "kitty_scrollback_nvim kitten ${pkgs.vimPlugins.kitty-scrollback-nvim}/python/kitty_scrollback_nvim.py";

          # Colors (adapted from: https://github.com/kdrag0n/base16-kitty/blob/master/templates/default-256.mustache)
          background = config.theme.colors.base00;
          foreground = config.theme.colors.base05;
          selection_background = config.theme.colors.base05;
          selection_foreground = config.theme.colors.base00;
          url_color = config.theme.colors.base04;
          cursor = config.theme.colors.base05;
          active_border_color = config.theme.colors.base03;
          inactive_border_color = config.theme.colors.base01;
          active_tab_background = config.theme.colors.base00;
          active_tab_foreground = config.theme.colors.base05;
          inactive_tab_background = config.theme.colors.base01;
          inactive_tab_foreground = config.theme.colors.base04;
          tab_bar_background = config.theme.colors.base01;

          # normal
          color0 = config.theme.colors.base00;
          color1 = config.theme.colors.base08;
          color2 = config.theme.colors.base0B;
          color3 = config.theme.colors.base0A;
          color4 = config.theme.colors.base0D;
          color5 = config.theme.colors.base0E;
          color6 = config.theme.colors.base0C;
          color7 = config.theme.colors.base05;

          # bright
          color8 = config.theme.colors.base03;
          color9 = config.theme.colors.base08;
          color10 = config.theme.colors.base0B;
          color11 = config.theme.colors.base0A;
          color12 = config.theme.colors.base0D;
          color13 = config.theme.colors.base0E;
          color14 = config.theme.colors.base0C;
          color15 = config.theme.colors.base07;

          # extended base16 colors
          color16 = config.theme.colors.base09;
          color17 = config.theme.colors.base0F;
          color18 = config.theme.colors.base01;
          color19 = config.theme.colors.base02;
          color20 = config.theme.colors.base04;
          color21 = config.theme.colors.base06;

          # Scrollback
          scrollback_lines = 10000;
          scrollback_pager_history_size = 300; # MB

          # Window
          window_padding_width = 6;

          tab_bar_edge = "top";
          tab_bar_style = "slant";

          # Disable audio
          enable_audio_bell = false;
        };
      };
    };
  };
}
