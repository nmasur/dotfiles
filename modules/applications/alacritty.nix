{ pkgs, user, font, ... }: {

  home-manager.users.${user} = {
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
          normal = { family = font.name; };
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
            background = "0x1d2021";
            foreground = "0xd5c4a1";
          };
          cursor = {
            text = "0x1d2021";
            cursor = "0xd5c4a1";
          };
          normal = {
            black = "0x1d2021";
            red = "0xfb4934";
            green = "0xb8bb26";
            yellow = "0xfabd2f";
            blue = "0x83a598";
            magenta = "0xd3869b";
            cyan = "0x8ec07c";
            white = "0xd5c4a1";
          };
          bright = {
            black = "0x665c54";
            red = "0xfe8019";
            green = "0x3c3836";
            yellow = "0x504945";
            blue = "0xbdae93";
            magenta = "0xebdbb2";
            cyan = "0xd65d0e";
            white = "0xfbf1c7";
          };
        };
        draw_bold_text_with_bright_colors = false;
      };
    };
  };
}
