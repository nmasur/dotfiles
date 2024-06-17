{
  config,
  pkgs,
  lib,
  ...
}:
{

  options = {
    wezterm = {
      enable = lib.mkEnableOption {
        description = "Enable WezTerm terminal.";
        default = false;
      };
    };
  };

  config = lib.mkIf (config.gui.enable && config.wezterm.enable) {

    # Set the Rofi-Systemd terminal for viewing logs
    # Using optionalAttrs because only available in NixOS
    environment =
      { }
      // lib.attrsets.optionalAttrs (builtins.hasAttr "sessionVariables" config.environment) {
        sessionVariables.ROFI_SYSTEMD_TERM = "${pkgs.wezterm}/bin/wezterm";
      };

    home-manager.users.${config.user} = {

      # Set the i3 terminal
      xsession.windowManager.i3.config.terminal = lib.mkIf pkgs.stdenv.isLinux "wezterm";

      # Set the Rofi terminal for running programs
      programs.rofi.terminal = lib.mkIf pkgs.stdenv.isLinux "${pkgs.wezterm}/bin/wezterm";

      # Display images in the terminal
      programs.fish.shellAliases = {
        icat = lib.mkForce "wezterm imgcat";
      };

      programs.wezterm = {
        enable = true;
        colorSchemes = {
          myTheme = {
            background = config.theme.colors.base00;
            foreground = config.theme.colors.base05;
            cursor_bg = config.theme.colors.base05;
            cursor_fg = config.theme.colors.base00;
            cursor_border = config.theme.colors.base05;
            selection_bg = config.theme.colors.base05;
            selection_fg = config.theme.colors.base00;
            scrollbar_thumb = config.theme.colors.base03;
            ansi = [
              config.theme.colors.base01 # black
              config.theme.colors.base0F # maroon
              config.theme.colors.base0B # green
              config.theme.colors.base0A # olive
              config.theme.colors.base0D # navy
              config.theme.colors.base0E # purple
              config.theme.colors.base0C # teal
              config.theme.colors.base06 # silver
            ];
            brights = [
              config.theme.colors.base04 # grey
              config.theme.colors.base08 # red
              config.theme.colors.base0B # lime
              config.theme.colors.base0A # yellow
              config.theme.colors.base0D # blue
              config.theme.colors.base0E # fuchsia
              config.theme.colors.base0C # aqua
              config.theme.colors.base07 # white
            ];
            compose_cursor = config.theme.colors.base09; # orange
            copy_mode_active_highlight_bg = {
              Color = config.theme.colors.base03;
            };
            copy_mode_active_highlight_fg = {
              Color = config.theme.colors.base07;
            };
            copy_mode_inactive_highlight_bg = {
              Color = config.theme.colors.base02;
            };
            copy_mode_inactive_highlight_fg = {
              Color = config.theme.colors.base06;
            };
            quick_select_label_bg = {
              Color = config.theme.colors.base02;
            };
            quick_select_label_fg = {
              Color = config.theme.colors.base06;
            };
            quick_select_match_bg = {
              Color = config.theme.colors.base03;
            };
            quick_select_match_fg = {
              Color = config.theme.colors.base07;
            };
          };
        };
        extraConfig = ''
          return {
              color_scheme = "myTheme",

              -- Scrollback
              scrollback_lines = 10000,

              -- Window
              window_padding = {
                left = 6,
                right = 6,
                top = 0,
                bottom = 0,
              },

              -- Disable audio
              audible_bell = "Disabled",

              initial_rows = 80,
              initial_cols = 200,

              font = wezterm.font 'VictorMono Nerd Font',
              font_size = 18.0,
          }
        '';
      };
    };
  };
}
