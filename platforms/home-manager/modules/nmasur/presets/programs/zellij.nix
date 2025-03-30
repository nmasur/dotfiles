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
      shellAbbrs.z = "zellij";
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

      # Not yet available in unstable
      # attachExistingSession = true;
      # exitShellOnExit = true;

      settings = {
        default_mode = "locked";
        # default_layout = "compact-top";
        # Remove border
        pane_frames = false;
        # Scrollback
        scrollback_editor = config.home.sessionVariables.EDITOR;

        show_startup_tips = false;

        # plugins = {
        #   autolock = {
        #     _props = {
        #       location = "https://github.com/fresh2dev/zellij-autolock/releases/download/0.2.2/zellij-autolock.wasm";
        #     };
        #     is_enabled = {
        #       _args = [ true ];
        #     };
        #     triggers = {
        #       _args = [ "vim|nvim|hx|git|fzf|zoxide|atuin|gh" ];
        #     };
        #     reaction_seconds = {
        #       _args = [ "0.3" ];
        #     };
        #     print_to_log = {
        #       _args = [ true ];
        #     };
        #   };
        # };
        # load_plugins = {
        #   autolock = { };
        # };
        keybinds = {
          normal = {
          };
          session = {
            "bind \"w\"" = {
              LaunchOrFocusPlugin = {
                _args = [ "session-manager" ];
                floating = true;
                move_to_focused_tab = true;
              };
              SwitchToMode = {
                _args = [ "locked" ];
              };
            };
          };
          shared = {
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
            "bind \"Super Shift ]\"" = {
              "GoToNextTab" = { };
            };
            "bind \"Super Shift [\"" = {
              "GoToPreviousTab" = { };
            };
            "bind \"Super t\"" = {
              "NewTab" = { };
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
