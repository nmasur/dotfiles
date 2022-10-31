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
          font = { size = 14.0; };
          key_bindings = [
            # Used for word completion in fish_user_key_bindings
            {
              key = "L";
              mods = "Control|Shift";
              chars = "\\x1F";
            }
            # Used for searching nixpkgs in fish_user_key_bindings
            {
              key = "N";
              mods = "Control|Shift";
              chars = "\\x11F";
            }
            {
              key = "H";
              mods = "Control|Shift";
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
              background = config.colorscheme.base00;
              foreground = config.colorscheme.base05;
            };
            cursor = {
              text = "#1d2021";
              cursor = config.colorscheme.base05;
            };
            normal = {
              black = "#1d2021";
              red = config.colorscheme.base08;
              green = config.colorscheme.base0B;
              yellow = config.colorscheme.base0A;
              blue = config.colorscheme.base0D;
              magenta = config.colorscheme.base0E;
              cyan = config.colorscheme.base0C;
              white = config.colorscheme.base05;
            };
            bright = {
              black = config.colorscheme.base03;
              red = config.colorscheme.base09;
              green = config.colorscheme.base01;
              yellow = config.colorscheme.base02;
              blue = config.colorscheme.base04;
              magenta = config.colorscheme.base06;
              cyan = config.colorscheme.base0F;
              white = config.colorscheme.base07;
            };
          };
          draw_bold_text_with_bright_colors = false;
        };
      };
    };
  };
}
