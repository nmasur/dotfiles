{ pkgs, identity, gui, ... }: {

  home-manager.users.${identity.user} = {
    xsession.windowManager.i3.config.terminal = "alacritty";
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
        };
        scrolling.history = 10000;
        font = {
          size = 14.0;
          normal = { family = gui.font.name; };
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
        ];
        colors = {
          primary = {
            background = "#282828";
            foreground = "#d5c4a1";
          };
          cursor = {
            text = "#1d2021";
            cursor = "#d5c4a1";
          };
          normal = {
            black = "#1d2021";
            red = "#fb4934";
            green = "#b8bb26";
            yellow = "#fabd2f";
            blue = "#83a598";
            magenta = "#d3869b";
            cyan = "#8ec07c";
            white = "#d5c4a1";
          };
          bright = {
            black = "#665c54";
            red = "#fe8019";
            green = "#3c3836";
            yellow = "#504945";
            blue = "#bdae93";
            magenta = "#ebdbb2";
            cyan = "#d65d0e";
            white = "#fbf1c7";
          };
        };
        draw_bold_text_with_bright_colors = false;
      };
    };
  };
}
