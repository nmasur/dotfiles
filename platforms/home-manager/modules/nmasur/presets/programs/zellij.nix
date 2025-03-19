{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.zellij;
in

{

  options.nmasur.presets.programs.zellij.enable = lib.mkEnableOption "Zellij terminal multiplexer";

  config = lib.mkIf cfg.enable {

    programs.zellij = {

      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;

      settings = {
        # Remove border
        pane_frames = false;
        keybinds = {
          # _props = {
          # clear-defaults = true;
          # };
          unbind = {
            _args = [
              "Ctrl g"
              "Ctrl h"
              "Ctrl n"
              "Ctrl o"
              "Ctrl p"
              "Ctrl q"
              "Ctrl s"
            ];
          };
          normal = {
            "bind \"Alt l\"" = {
              SwitchToMode = {
                _args = [ "locked" ];
              };
            };
            "bind \"Alt p\"" = {
              SwitchToMode = {
                _args = [ "pane" ];
              };
            };
            "bind \"Alt t\"" = {
              SwitchToMode = {
                _args = [ "tab" ];
              };
            };
            "bind \"Alt r\"" = {
              SwitchToMode = {
                _args = [ "resize" ];
              };
            };
            "bind \"Alt m\"" = {
              SwitchToMode = {
                _args = [ "move" ];
              };
            };
            "bind \"Alt k\"" = {
              SwitchToMode = {
                _args = [ "search" ];
              };
            };
            "bind \"Alt o\"" = {
              SwitchToMode = {
                _args = [ "session" ];
              };
            };
            "bind \"Alt q\"" = {
              "Quit" = { };
            };
          };
          locked = {
            "bind \"Alt l\"" = {
              SwitchToMode = {
                _args = [ "Normal" ];
              };
            };
          };

        };
        theme = "custom";
        themes.custom = {
          fg = "${config.theme.colors.base05}";
          bg = "${config.theme.colors.base02}";
          black = "${config.theme.colors.base00}";
          red = "${config.theme.colors.base08}";
          green = "${config.theme.colors.base0B}";
          yellow = "${config.theme.colors.base0A}";
          blue = "${config.theme.colors.base0D}";
          magenta = "${config.theme.colors.base0E}";
          cyan = "${config.theme.colors.base0C}";
          white = "${config.theme.colors.base05}";
          orange = "${config.theme.colors.base09}";
        };
      };

    };

  };

}
