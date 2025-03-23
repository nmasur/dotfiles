{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.zellij;
in

{

  options.nmasur.presets.programs.zellij.enable = lib.mkEnableOption "Zellij terminal multiplexer";

  config = lib.mkIf cfg.enable {

    home.packages = [ pkgs.zellij-switch ];

    programs.fish = {
      functions = {
        zellij-session = {
          # description = "Open a session in Zellij";
          body = # fish
            ''
              zoxide query --interactive | xargs -I {} sh -c 'zellij pipe --plugin file:$(which zellij-switch.wasm) -- "--cwd {} --layout default --session $(basename {})"' \\;
            '';
        };
      };
    };

    xdg.configFile."zellij/layouts/compact-top.kdl".text = # kdl
      ''
        layout {
          pane size=1 borderless=true {
            plugin location="compact-bar"
          }
          pane
        }
      '';

    xdg.configFile."zellij/layouts/default.kdl".text = # kdl
      ''
        layout {
            pane size=1 borderless=true {
                plugin location="tab-bar"
            }
            pane
            pane size=1 borderless=true {
                plugin location="status-bar"
            }
        }
      '';

    programs.zellij = {

      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;

      settings = {
        # default_layout = "compact-top";
        # Remove border
        pane_frames = false;
        # Scrollback
        scrollback_editor = config.home.sessionVariables.EDITOR;
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
              "Alt i"
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
                _args = [ "scroll" ];
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
            "bind \"Alt Shift p\"" = {
              "Run" = {
                _args = [
                  "${pkgs.fish}/bin/fish"
                  "-c"
                  "zellij-session"
                ];
                close_on_exit = true;
              };
            };
            "bind \"Super t\"" = {
              "NewTab" = { };
            };
            "bind \"Super Shift ]\"" = {
              "GoToPreviousTab" = { };
            };
            "bind \"Super Shift [\"" = {
              "GoToNextTab" = { };
            };
            "bind \"Ctrl Tab\"" = {
              "GoToNextTab" = { };
            };
            "bind \"Ctrl Shift Tab\"" = {
              "GoToPreviousTab" = { };
            };
            "bind \"Alt Shift i\"" = {
              "MoveTab" = {
                _args = [ "Left" ];
              };
            };
            "bind \"Alt Shift o\"" = {
              "MoveTab" = {
                _args = [ "Right" ];
              };
            };
          };
          locked = {
            "bind \"Alt l\"" = {
              SwitchToMode = {
                _args = [ "Normal" ];
              };
            };
          };
          session = {
            unbind = {
              _args = [ "Alt o" ];
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
