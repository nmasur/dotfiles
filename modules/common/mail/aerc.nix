{
  config,
  pkgs,
  lib,
  ...
}:
{

  options.mail.aerc.enable = lib.mkEnableOption "Aerc email.";

  config = lib.mkIf config.mail.aerc.enable {

    home-manager.users.${config.user} = {

      home.packages = with pkgs; [
        w3m # Render HTML
        dante # Socksify for rendering HTML
      ];

      programs.aerc = {
        enable = true;
        extraBinds = {
          # Binds are of the form <key sequence> = <command to run>
          # To use '=' in a key sequence, substitute it with "Eq": "<Ctrl+Eq>"
          # If you wish to bind #, you can wrap the key sequence in quotes: "#" = quit
          global = {
            "<C-p>" = ":prev-tab<Enter>";
            "<C-n>" = ":next-tab <Enter>";
            "<C-t>" = ":term<Enter>";
            "?" = ":help keys<Enter>";
          };

          messages = {
            q = ":quit<Enter>";

            j = ":next <Enter>";
            "<Down>" = ":next<Enter>";
            "<C-d>" = ":next 50%<Enter>";
            "<C-f>" = ":next 100%<Enter>";
            "<PgDn>" = ":next 100%<Enter>";

            k = ":prev <Enter>";
            "<Up>" = ":prev<Enter>";
            "<C-u>" = ":prev 50%<Enter>";
            "<C-b>" = ":prev 100%<Enter>";
            "<PgUp>" = ":prev 100%<Enter>";
            g = ":select 0 <Enter>";
            G = ":select -1<Enter>";

            J = ":next-folder <Enter>";
            K = ":prev-folder<Enter>";
            H = ":collapse-folder<Enter>";
            L = ":expand-folder<Enter>";

            v = ":mark -t<Enter>";
            V = ":mark -v<Enter>";

            T = ":toggle-threads<Enter>";

            "<Enter>" = ":view<Enter>";
            d = ":prompt 'Really delete this message?' 'delete-message'<Enter>";
            D = ":move Trash<Enter>";
            A = ":archive flat<Enter>";

            C = ":compose<Enter>";

            rr = ":reply -a<Enter>";
            rq = ":reply -aq<Enter>";
            Rr = ":reply<Enter>";
            Rq = ":reply -q<Enter>";

            c = ":cf<space>";
            "$" = ":term<space>";
            "!" = ":term<space>";
            "|" = ":pipe<space>";

            "/" = ":search<space>-a<space>";
            "\\" = ":filter <space>";
            n = ":next-result<Enter>";
            N = ":prev-result<Enter>";
            "<Esc>" = ":clear<Enter>";
          };

          "messages:folder=Drafts" = {
            "<Enter>" = ":recall<Enter>";
          };

          view = {
            "/" = ":toggle-key-passthrough <Enter> /";
            q = ":close<Enter>";
            O = ":open<Enter>";
            S = ":save<space>";
            "|" = ":pipe<space>";
            D = ":move Trash<Enter>";
            A = ":archive flat<Enter>";

            "<C-l>" = ":open-link <space>";

            f = ":forward <Enter>";
            rr = ":reply -a<Enter>";
            rq = ":reply -aq<Enter>";
            Rr = ":reply<Enter>";
            Rq = ":reply -q<Enter>";

            H = ":toggle-headers<Enter>";
            "<C-k>" = ":prev-part<Enter>";
            "<C-j>" = ":next-part<Enter>";
            J = ":next <Enter>";
            K = ":prev<Enter>";
          };

          "view::passthrough" = {
            "$noinherit" = "true";
            "$ex" = "<C-x>";
            "<Esc>" = ":toggle-key-passthrough<Enter>";
          };

          compose = {
            # Keybindings used when the embedded terminal is not selected in the compose
            # view
            "$noinherit" = "true";
            "$ex" = "<C-x>";
            "<C-k>" = ":prev-field<Enter>";
            "<C-j>" = ":next-field<Enter>";
            "<A-p>" = ":switch-account -p<Enter>";
            "<A-n>" = ":switch-account -n<Enter>";
            "<tab>" = ":next-field<Enter>";
            "<C-p>" = ":prev-tab<Enter>";
            "<C-n>" = ":next-tab<Enter>";
          };

          "compose::editor" = {
            # Keybindings used when the embedded terminal is selected in the compose view
            "$noinherit" = "true";
            "$ex" = "<C-x>";
            "<C-k>" = ":prev-field<Enter>";
            "<C-j>" = ":next-field<Enter>";
            "<C-p>" = ":prev-tab<Enter>";
            "<C-n>" = ":next-tab<Enter>";
          };

          "compose::review" = {
            # Keybindings used when reviewing a message to be sent
            y = ":send <Enter>";
            n = ":abort<Enter>";
            p = ":postpone<Enter>";
            q = ":choose -o d discard abort -o p postpone postpone<Enter>";
            e = ":edit<Enter>";
            a = ":attach<space>";
            d = ":detach<space>";
          };

          terminal = {
            "$noinherit" = "true";
            "$ex" = "<C-x>";
            "<C-p>" = ":prev-tab<Enter>";
            "<C-n>" = ":next-tab<Enter>";
          };
        };
        extraConfig = {
          general = {
            unsafe-accounts-conf = true;
            # log-file = "~/.cache/aerc.log";
            # log-level = "debug";
          };
          viewer = {
            pager = "${pkgs.less}/bin/less -R";
          };
          filters = {
            "text/plain" = "${pkgs.aerc}/libexec/aerc/filters/colorize";
            "text/calendar" = "${pkgs.gawk}/bin/awk -f ${pkgs.aerc}/libexec/aerc/filters/calendar";
            "text/html" = "${pkgs.aerc}/libexec/aerc/filters/html | ${pkgs.aerc}/libexec/aerc/filters/colorize"; # Requires w3m, dante
            # "text/*" =
            #   ''${pkgs.bat}/bin/bat -fP --file-name="$AERC_FILENAME "'';
            "message/delivery-status" = "${pkgs.aerc}/libexec/aerc/filters/colorize";
            "message/rfc822" = "${pkgs.aerc}/libexec/aerc/filters/colorize";
            "application/x-sh" = "${pkgs.bat}/bin/bat -fP -l sh";
            "application/pdf" = "${pkgs.zathura}/bin/zathura -";
            "audio/*" = "${pkgs.mpv}/bin/mpv -";
            "image/*" = "${pkgs.feh}/bin/feh -";
          };
        };
      };
      accounts.email.accounts.home.aerc = {
        enable = true;
        extraAccounts = {
          check-mail = "5m";
          check-mail-cmd = "${pkgs.isync}/bin/mbsync -a";
          check-mail-timeout = "15s";
        };
      };

      xdg.desktopEntries.aerc = lib.mkIf pkgs.stdenv.isLinux {
        name = "aerc";
        exec = "kitty aerc %u";
      };
      xsession.windowManager.i3.config.keybindings = lib.mkIf pkgs.stdenv.isLinux {
        "${
          config.home-manager.users.${config.user}.xsession.windowManager.i3.config.modifier
        }+Shift+e" = "exec ${
          # Don't name the script `aerc` or it will affect grep
          builtins.toString (
            pkgs.writeShellScript "focus-mail.sh" ''
              count=$(ps aux | grep -c aerc)
              if [ "$count" -eq 1 ]; then
                  i3-msg "exec --no-startup-id kitty --class aerc aerc"
                  sleep 0.25
              fi
              i3-msg "[class=aerc] focus"
            ''
          )
        }";
      };

      programs.fish.shellAbbrs = {
        ae = "aerc";
      };
    };
  };
}
