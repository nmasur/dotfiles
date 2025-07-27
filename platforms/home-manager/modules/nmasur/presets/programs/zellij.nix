{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.zellij;

  zellij-switch-to-last = pkgs.writeShellScriptBin "zellij-switch-to-last" ''
    TARGET_SESSION=$(cat ~/.local/state/zellij-last-session)
    if [ -z "$TARGET_SESSION" ]; then
      return 1
    fi
    echo "$ZELLIJ_SESSION_NAME" > ~/.local/state/zellij-last-session
    zellij pipe --plugin file:$(which zellij-switch.wasm) -- "--session $TARGET_SESSION"
  '';
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
              set TARGET_DIR $(zoxide query --interactive)
              if test -z $TARGET_DIR
                return 0
              end
              if test "$TARGET_DIR" = $(pwd)
                return 1
              end
              echo "$ZELLIJ_SESSION_NAME" > ~/.local/state/zellij-last-session
              zellij pipe --plugin file:$(which zellij-switch.wasm) -- "--cwd $TARGET_DIR --layout default --session $(basename $TARGET_DIR)"
            '';
        };
        gh-run = {
          body = # fish
            ''
              zellij action new-pane --start-suspended -- gh run watch
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

      # Auto start on shell init
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableZshIntegration = false;
      attachExistingSession = false;
      exitShellOnExit = false;

      settings = {
        default_mode = "locked";
        # default_layout = "compact-top";
        # Remove border
        pane_frames = false;
        # Scrollback
        scrollback_editor = config.home.sessionVariables.EDITOR;

        show_startup_tips = false;

        keybinds = {
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
          scroll = {
            "bind \"e\"" = {
              EditScrollback = { };
              SwitchToMode = {
                _args = [ "locked" ];
              };
            };
          };
          shared = {
            "bind \"Alt Shift s\"" = {
              Run = {
                _args = [
                  (lib.getExe zellij-switch-to-last)
                ];
                close_on_exit = true;
              };
            };
            "bind \"Alt Shift p\"" = {
              Run = {
                _args = [
                  "${pkgs.fish}/bin/fish"
                  "-c"
                  "zellij-session"
                ];
                close_on_exit = true;
              };
            };
            "bind \"Alt Shift h\"" = {
              Run = {
                _args = [
                  (lib.getExe config.nmasur.presets.programs.nixpkgs.commands.rebuildHome)
                ];
                # close_on_exit = false;
              };
            };
            "bind \"Alt Shift r\"" = {
              Run = {
                _args = [
                  (lib.getExe config.nmasur.presets.programs.nixpkgs.commands.rebuildNixos)
                ];
                # close_on_exit = false;
              };
            };
            "bind \"Alt Shift w\"" = {
              Run = {
                _args = [
                  (lib.getExe pkgs.gh)
                  "run"
                  "watch"
                ];
                # direction = "Right";
                # close_on_exit = false;
                # start_suspended = true;
              };
            };
            "bind \"Alt Shift l\"" = {
              Run = {
                _args = [
                  (lib.getExe pkgs.gh)
                  "run"
                  "view"
                  "--log"
                ];
              };
            };
            "bind \"Alt Shift f\"" = {
              Run = {
                _args = [
                  (lib.getExe pkgs.gh)
                  "run"
                  "view"
                  "--log-failed"
                ];
              };
            };
            "bind \"Alt Shift j\"" = {
              Run = {
                _args = [
                  (lib.getExe pkgs.lazyjj)
                ];
                close_on_exit = true;
              };
            };
            "bind \"Super Shift ]\"" = {
              GoToNextTab = { };
            };
            "bind \"Super Shift [\"" = {
              GoToPreviousTab = { };
            };
            "bind \"Ctrl Tab\"" = {
              GoToNextTab = { };
            };
            "bind \"Ctrl Shift Tab\"" = {
              GoToPreviousTab = { };
            };
            "bind \"Super t\"" = lib.mkIf pkgs.stdenv.isDarwin {
              NewTab = { };
            };
            "bind \"Alt t\"" = lib.mkIf pkgs.stdenv.isLinux {
              NewTab = { };
            };
            "bind \"Super k\"" = lib.mkIf pkgs.stdenv.isDarwin {
              SwitchToMode = {
                _args = [ "scroll" ];
              };
            };
            "bind \"Super Shift e\"" = lib.mkIf pkgs.stdenv.isDarwin {
              EditScrollback = { };
              SwitchToMode = {
                _args = [ "locked" ];
              };
            };
            "bind \"Alt Shift e\"" = lib.mkIf pkgs.stdenv.isLinux {
              EditScrollback = { };
              SwitchToMode = {
                _args = [ "locked" ];
              };
            };
            "bind \"Alt l\"" = {
              MoveFocusOrTab = {
                _args = [ "Right" ];
              };
            };
            "bind \"Alt h\"" = {
              MoveFocusOrTab = {
                _args = [ "Left" ];
              };
            };
          };

        };
        theme = "custom";
        themes.custom = {
          fg = "${config.theme.colors.base03}";
          bg = "${config.theme.colors.base02}";
          black = "${config.theme.colors.base00}";
          red = "${config.theme.colors.base08}";
          green = "${config.theme.colors.base04}";
          yellow = "${config.theme.colors.base0A}";
          blue = "${config.theme.colors.base0D}";
          magenta = "${config.theme.colors.base0E}";
          cyan = "${config.theme.colors.base0C}";
          white = "${config.theme.colors.base04}";
          orange = "${config.theme.colors.base09}";
        };
      };

    };

  };

}
