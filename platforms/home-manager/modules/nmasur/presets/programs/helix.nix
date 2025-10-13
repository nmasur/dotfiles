{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.helix;
in

{

  options.nmasur.presets.programs.helix.enable = lib.mkEnableOption "Helix text editor";

  config = lib.mkIf cfg.enable {

    # Use Neovim as the editor for git commit messages
    programs.git.extraConfig.core.editor = lib.mkForce "${lib.getExe pkgs.helix}";
    programs.jujutsu.settings.ui.editor = lib.mkForce "${lib.getExe pkgs.helix}";

    # Set Neovim as the default app for text editing and manual pages
    home.sessionVariables = {
      EDITOR = lib.mkForce "${lib.getExe pkgs.helix}";
      MANPAGER = lib.mkForce "sh -c 'col -bx | ${lib.getExe pkgs.helix}'";
      MANWIDTH = 87;
      MANROFFOPT = "-c";
    };

    # Create quick aliases for launching Helix
    programs.fish = {
      shellAbbrs = {
        h = lib.mkForce "hx";
      };
    };

    programs.helix = {

      enable = true;

      package = pkgs.helix; # pkgs.evil-helix

      languages = {

        language-server.nixd = {
          command = "${pkgs.nixd}/bin/nixd";
        };

        language-server.ty = {
          command = "${pkgs.ty}/bin/ty";
        };

        language-server.fish-lsp = {
          command = "${pkgs.fish-lsp}/bin/fish-lsp";
        };

        language-server.yaml-language-server = {
          command = lib.getExe pkgs.yaml-language-server;
        };

        language-server.marksman = {
          command = lib.getExe pkgs.marksman;
        };

        language-server.terraform-ls = {
          command = "${lib.getExe pkgs.terraform-ls}";
          args = [ "serve" ];
        };

        language-server.bash-language-server = {
          command = lib.getExe (
            pkgs.bash-language-server.overrideAttrs {
              buildInputs = [
                pkgs.shellcheck
                pkgs.shfmt
              ];
            }
          );
        };

        language = [
          {
            name = "nix";
            auto-format = true;
            language-servers = [ "nixd" ];
          }
          {
            name = "markdown";
            auto-format = false;
            language-servers = [ "marksman" ];
            formatter = {
              command = lib.getExe pkgs.mdformat;
              args = [ "-" ];
            };
            # Allows return key to continue the token on the next line
            comment-tokens = [
              "-"
              "+"
              "*"
              "- [ ]"
              ">"
            ];
          }
          {
            name = "tfvars";
            auto-format = true;
            language-servers = [ "terraform-ls" ];
            formatter = {
              command = lib.getExe pkgs.terraform;
              args = [
                "fmt"
                "-"
              ];
            };
          }
          {
            name = "hcl";
            auto-format = true;
            language-servers = [ "terraform-ls" ];
            formatter = {
              command = lib.getExe pkgs.terraform;
              args = [
                "fmt"
                "-"
              ];
            };
          }
          {
            name = "bash";
            auto-format = true;
          }
        ];

      };

      ignores = [
        "content/.obsidian/**"
        ".direnv/**"
      ];

      settings = {
        theme = "base16";

        keys.normal = {

          # Use the enter key to save the file
          ret = ":write";

          # Get out of multiple cursors and selection
          esc = [
            "collapse_selection"
            "keep_primary_selection"
          ];

          # Quit shortcuts
          space.q = ":quit-all";
          space.x = ":quit-all!";

          # Enable and disable inlay hints
          space.H = ":toggle lsp.display-inlay-hints";

          # Toggle floating pane
          space.t = ":sh zellij action toggle-floating-panes";

          # Today's note
          space.n = ":vsplit %sh{fish -c 'generate-today'}";

          # Open lazygit
          # Unfortunately, this breaks mouse input and the terminal after quitting Helix
          space.l = [
            ":write-all"
            ":new"
            ":insert-output ${lib.getExe pkgs.lazygit} > /dev/tty"
            ":buffer-close!"
            ":redraw"
            ":reload-all"
            ":set mouse false"
            ":set mouse true"
          ];

          # Commandline git blame
          space.B = ":echo %sh{git log -n1 --date=short --pretty=format:'%%h %%ad %%s' $(git blame -L %{cursor_line},+1 \"%{buffer_name}\" | cut -d' ' -f1)}";

          # Open yazi
          # https://github.com/sxyazi/yazi/pull/2461
          # Won't work until next Helix release
          C-y = [
            ":sh rm -f /tmp/unique-file"
            ":insert-output ${lib.getExe pkgs.yazi} %{buffer_name} --chooser-file=/tmp/unique-file"
            ":insert-output echo \\x1b[?1049h\\x1b[?2004h > /dev/tty"
            ":open %sh{cat /tmp/unique-file}"
            ":redraw"
          ];

          # Extend selection above
          X = "select_line_above";

          # Move lines up or down
          A-j = [
            "extend_to_line_bounds"
            "delete_selection"
            "paste_after"
          ];
          A-k = [
            "extend_to_line_bounds"
            "delete_selection"
            "move_line_up"
            "paste_before"
          ];

          A-S-ret = [
            "open_above"
            "normal_mode"
          ];
          A-ret = [
            "open_below"
            "normal_mode"
          ];

        };

        keys.insert = {
          # Allows not continuing the comment
          "A-ret" = [
            "insert_newline"
            "extend_to_line_bounds"
            "delete_selection"
            "insert_newline"
            "move_line_up"
            "insert_mode"
          ];
        };

        editor = {

          # Change cursors depending on the mode
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };

          # Text width
          soft-wrap = {
            enable = true;
          };

          # View line numbers relative to the current cursors
          line-number = "relative";

          # Show hidden files
          file-picker = {
            hidden = false; # Show hidden files
            git-ignore = true; # Skip gitignore files
            git-global = true; # Skip global gitignore files
            git-exclude = true; # Skip excluded files
          };

          # Show whitespace visible to the user
          # Waiting for trailing whitespace option ideally
          whitespace = {
            render = {
              # space = "all";
              tab = "all";
            };
            characters = {
              # space = "·";
              tab = "→";
            };
          };
        };

      };

      themes."${config.programs.helix.settings.theme}" = {
        "attributes" = config.theme.colors.base09;
        "comment" = {
          fg = config.theme.colors.base03;
          modifiers = [ "italic" ];
        };
        "constant" = config.theme.colors.base09;
        "constant.character.escape" = config.theme.colors.base0C;
        "constant.numeric" = config.theme.colors.base09;
        "constructor" = config.theme.colors.base0D;
        "debug" = config.theme.colors.base03;
        "diagnostic" = {
          modifiers = [ "underlined" ];
        };
        "diff.delta" = config.theme.colors.base09;
        "diff.minus" = config.theme.colors.base08;
        "diff.plus" = config.theme.colors.base0B;
        "error" = config.theme.colors.base08;
        "function" = config.theme.colors.base0D;
        "hint" = config.theme.colors.base03;
        "info" = config.theme.colors.base0D;
        "keyword" = config.theme.colors.base0E;
        "label" = config.theme.colors.base0E;
        "namespace" = config.theme.colors.base0E;
        "operator" = config.theme.colors.base05;
        "special" = config.theme.colors.base0D;
        "string" = config.theme.colors.base0B;
        "type" = config.theme.colors.base0A;
        "variable" = config.theme.colors.base08;
        "variable.other.member" = config.theme.colors.base05;
        "warning" = config.theme.colors.base09;
        "markup.bold" = {
          fg = config.theme.colors.base0A;
          modifiers = [ "bold" ];
        };
        "markup.heading" = config.theme.colors.base0D;
        "markup.italic" = {
          fg = config.theme.colors.base0E;
          modifiers = [ "italic" ];
        };
        "markup.link.text" = config.theme.colors.base08;
        "markup.link.url" = {
          fg = config.theme.colors.base09;
          modifiers = [ "underlined" ];
        };
        "markup.list" = config.theme.colors.base08;
        "markup.quote" = config.theme.colors.base0C;
        "markup.raw" = config.theme.colors.base0B;
        "markup.strikethrough" = {
          modifiers = [ "crossed_out" ];
        };
        "diagnostic.hint" = {
          underline = {
            style = "curl";
          };
        };
        "diagnostic.info" = {
          underline = {
            style = "curl";
          };
        };
        "diagnostic.warning" = {
          underline = {
            style = "curl";
          };
        };
        "diagnostic.error" = {
          underline = {
            style = "curl";
          };
        };
        "ui.background" = {
          bg = config.theme.colors.base00;
        };
        "ui.bufferline.active" = {
          fg = config.theme.colors.base00;
          bg = config.theme.colors.base03;
          modifiers = [ "bold" ];
        };
        "ui.bufferline" = {
          fg = config.theme.colors.base04;
          bg = config.theme.colors.base00;
        };
        "ui.cursor" = {
          fg = config.theme.colors.base04;
          modifiers = [ "reversed" ];
        };
        "ui.cursor.insert" = {
          fg = config.theme.colors.base0A;
          modifiers = [ "reversed" ];
        };
        "ui.cursorline.primary" = {
          fg = config.theme.colors.base05;
          bg = config.theme.colors.base01;
        };
        "ui.cursor.match" = {
          fg = config.theme.colors.base03;
          modifiers = [ "reversed" ];
        };
        "ui.cursor.select" = {
          fg = config.theme.colors.base04;
          modifiers = [ "reversed" ];
        };
        "ui.gutter" = {
          bg = config.theme.colors.base00;
        };
        "ui.help" = {
          fg = config.theme.colors.base06;
          bg = config.theme.colors.base01;
        };
        "ui.linenr" = {
          fg = config.theme.colors.base03;
          bg = config.theme.colors.base00;
        };
        "ui.linenr.selected" = {
          fg = config.theme.colors.base04;
          bg = config.theme.colors.base01;
          modifiers = [ "bold" ];
        };
        "ui.menu" = {
          fg = config.theme.colors.base05;
          bg = config.theme.colors.base01;
        };
        "ui.menu.scroll" = {
          fg = config.theme.colors.base03;
          bg = config.theme.colors.base01;
        };
        "ui.menu.selected" = {
          fg = config.theme.colors.base01;
          bg = config.theme.colors.base04;
        };
        "ui.popup" = {
          bg = config.theme.colors.base01;
        };
        "ui.selection" = {
          bg = config.theme.colors.base01;
        };
        "ui.selection.primary" = {
          bg = config.theme.colors.base02;
        };
        "ui.statusline" = {
          fg = config.theme.colors.base04;
          bg = config.theme.colors.base01;
        };
        "ui.statusline.inactive" = {
          bg = config.theme.colors.base01;
          fg = config.theme.colors.base03;
        };
        "ui.statusline.insert" = {
          fg = config.theme.colors.base00;
          bg = config.theme.colors.base0B;
        };
        "ui.statusline.normal" = {
          fg = config.theme.colors.base00;
          bg = config.theme.colors.base03;
        };
        "ui.statusline.select" = {
          fg = config.theme.colors.base00;
          bg = config.theme.colors.base0F;
        };
        "ui.text" = config.theme.colors.base05;
        "ui.text.focus" = config.theme.colors.base05;
        "ui.virtual.indent-guide" = {
          fg = config.theme.colors.base03;
        };
        "ui.virtual.inlay-hint" = {
          fg = config.theme.colors.base03;
        };
        "ui.virtual.ruler" = {
          bg = config.theme.colors.base01;
        };
        "ui.virtual.jump-label" = {
          fg = config.theme.colors.base0A;
          modifiers = [ "bold" ];
        };
        "ui.window" = {
          bg = config.theme.colors.base01;
        };
      };

    };

    # Create a desktop option for launching Helix from a file manager
    # (Requires launching the terminal and then executing Helix)
    xdg.desktopEntries.helix =
      lib.mkIf (pkgs.stdenv.isLinux && config.nmasur.presets.services.i3.enable)
        {
          name = "Helix wrapper";
          exec = ''sh -c "${lib.getExe config.nmasur.presets.services.i3.terminal} --command='hx \$1'" _ %F ''; # TODO: change to work for any terminal
          mimeType = [
            "text/plain"
            "text/markdown"
          ];
        };
    xdg.mimeApps.defaultApplications = {
      "text/plain" = lib.mkBefore [ "Helix.desktop" ];
      "text/markdown" = lib.mkBefore [ "Helix.desktop" ];
    };

    home.packages = [
      (pkgs.writers.writeDashBin "xterm" ''${lib.getExe config.nmasur.presets.services.i3.terminal} +new-window --command"$@" '')
    ];

  };

}
