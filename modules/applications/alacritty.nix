{ config, pkgs, lib, ... }: {

  config = lib.mkIf config.gui.enable {
    home-manager.users.${config.user} = {
      xsession.windowManager.i3.config.terminal = "alacritty";
      programs.rofi.terminal = "${pkgs.alacritty}/bin/alacritty";
      programs.alacritty = {
        enable = true;
        settings = {
          window = {
            dimensions = {
              columns = 85;
              lines = 30;
            };
            padding = {
              x = 20;
              y = 20;
            };
            opacity = 1.0;
          };
          scrolling.history = 10000;
          font = {
            size = 14.0;
            normal = {
              family =
                builtins.head config.fonts.fontconfig.defaultFonts.monospace;
            };
          };
          key_bindings = [
            {
              key = "L";
              mods = "Control|Shift";
              chars = "\\x1F";
            }
            {
              key = "K";
              mods = "Control";
              mode = "~Vi";
              action = "ToggleViMode";
            }
            {
              key = "Return";
              mode = "Vi";
              action = "ToggleViMode";
            }
            # Used to enable $ keybind in Vi mode
            {
              key = 5; # Scancode for key4
              mods = "Shift";
              mode = "Vi|~Search";
              action = "Last";
            }
          ];
          colors = {
            primary = {
              background = config.gui.colorscheme.base00;
              foreground = config.gui.colorscheme.base05;
            };
            cursor = {
              text = "#1d2021";
              cursor = config.gui.colorscheme.base05;
            };
            normal = {
              black = "#1d2021";
              red = config.gui.colorscheme.base08;
              green = config.gui.colorscheme.base0B;
              yellow = config.gui.colorscheme.base0A;
              blue = config.gui.colorscheme.base0D;
              magenta = config.gui.colorscheme.base0E;
              cyan = config.gui.colorscheme.base0C;
              white = config.gui.colorscheme.base05;
            };
            bright = {
              black = config.gui.colorscheme.base03;
              red = config.gui.colorscheme.base09;
              green = config.gui.colorscheme.base01;
              yellow = config.gui.colorscheme.base02;
              blue = config.gui.colorscheme.base04;
              magenta = config.gui.colorscheme.base06;
              cyan = config.gui.colorscheme.base0F;
              white = config.gui.colorscheme.base07;
            };
          };
          draw_bold_text_with_bright_colors = false;
        };
      };
    };
  };
}
