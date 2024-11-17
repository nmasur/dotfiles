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

  config =
    let
      font = config.home-manager.users.${config.user}.programs.kitty.font.name;
    in
    lib.mkIf (config.gui.enable && config.wezterm.enable) {

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
                config.theme.colors.base03 # grey
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
            local wezterm = require("wezterm")
            local config = wezterm.config_builder()
            config.check_for_updates = false
            config.color_scheme = "myTheme"

            -- Scrollback
            config.scrollback_lines = 10000

            -- Window
            config.window_padding = {
              left = 10,
              right = 10,
              top = 10,
              bottom = 10,
            }

            config.font = wezterm.font('${font}', { weight = 'Bold'})
            config.font_size = ${if pkgs.stdenv.isLinux then "14.0" else "18.0"}

            -- Fix color blocks instead of text
            config.front_end = "WebGpu"

            -- Tab Bar
            config.hide_tab_bar_if_only_one_tab = true
            config.window_frame = {
              font = wezterm.font('${font}', { weight = 'Bold'}),
              font_size = ${if pkgs.stdenv.isLinux then "12.0" else "16.0"},
            }

            config.colors = {
              tab_bar = {
                active_tab = {
                  bg_color = '${config.theme.colors.base00}',
                  fg_color = '${config.theme.colors.base04}',
                },
              },
            }

            -- Disable audio
            config.audible_bell = "Disabled"

            config.initial_rows = 80
            config.initial_cols = 200

            config.unix_domains = {
              {
                name = 'unix',
              },
            }

            config.leader = {
              key = 'a',
              mods = 'CTRL',
              timeout_milliseconds = 2000,
            }

            config.keys = {
              -- Attach to muxer
              {
                key = 'a',
                mods = 'LEADER',
                action = wezterm.action.AttachDomain 'unix',
              },

              -- Detach from muxer
              {
                key = 'd',
                mods = 'LEADER',
                action = wezterm.action.DetachDomain { DomainName = 'unix' },
              },
              -- sends completion string for fish autosuggestions
              {
                key = 'Enter',
                mods = 'SHIFT',
                action = wezterm.action.SendString '\x1F'
              },
              -- ctrl-shift-h was "hide"
              {
                key = 'H',
                mods = 'SHIFT|CTRL',
                action = wezterm.action.DisableDefaultAssignment
              },
              -- alt-enter was "fullscreen"
              {
                key = 'Enter',
                mods = 'ALT',
                action = wezterm.action.DisableDefaultAssignment
              },
              -- make super-f "fullscreen"
              {
                key = 'f',
                mods = 'SUPER',
                action = wezterm.action.ToggleFullScreen
              },
              -- super-t open new tab in new dir
              {
                key = 't',
                mods = ${if pkgs.stdenv.isDarwin then "'SUPER'" else "'ALT'"},
                action = wezterm.action.SpawnCommandInNewTab {
                  cwd = wezterm.home_dir,
                },
              },
              -- shift-super-t open new tab in same dir
              {
                key = 't',
                mods = 'SUPER|SHIFT',
                action = wezterm.action.SpawnTab 'CurrentPaneDomain'
              },
              -- project switcher
              {
                 key = 'P',
                 mods = 'SUPER',
                 action = wezterm.action_callback(function(window, pane)
                   local choices = {}

                   wezterm.log_info "working?"

                   function scandir(directory)
                       local i, t, popen = 0, {}, io.popen
                       local pfile = popen('${pkgs.fd}/bin/fd --search-path "'..directory..'" --type directory --exact-depth 2 | ${pkgs.proximity-sort}/bin/proximity-sort "'..os.getenv("HOME").."/dev/work"..'"')
                       for filename in pfile:lines() do
                           i = i + 1
                           t[i] = filename
                       end
                       pfile:close()
                       return t
                   end

                   for _, v in pairs(scandir(os.getenv("HOME").."/dev")) do
                     table.insert(choices, { label = v })
                   end

                   window:perform_action(
                     wezterm.action.InputSelector {
                       action = wezterm.action_callback(function(window, pane, id, label)
                         if not id and not label then
                           wezterm.log_info "cancelled"
                         else
                           window:perform_action(
                             wezterm.action.SpawnCommandInNewTab {
                               cwd = label,
                             },
                             pane
                           )
                         end
                       end),
                       fuzzy = true,
                       title = "Select Project",
                       choices = choices,
                     },
                     pane
                   )
                 end),
              },
            }

            -- print the workspace name at the upper right
            wezterm.on("update-right-status", function(window, pane)
              window:set_right_status(window:active_workspace())
            end)
            -- load plugin
            local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
            -- set path to zoxide
            workspace_switcher.zoxide_path = "${pkgs.zoxide}/bin/zoxide"
            -- keymaps
            table.insert(config.keys, { key = "s", mods = "CTRL|SHIFT", action = workspace_switcher.switch_workspace() })
            -- table.insert(config.keys, { key = "t", mods = "CTRL|SHIFT", action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) })
            table.insert(config.keys, { key = "[", mods = "CTRL|SHIFT", action = wezterm.action.SwitchWorkspaceRelative(1) })
            table.insert(config.keys, { key = "]", mods = "CTRL|SHIFT", action = wezterm.action.SwitchWorkspaceRelative(-1) })

            return config
          '';
        };
      };
    };
}
