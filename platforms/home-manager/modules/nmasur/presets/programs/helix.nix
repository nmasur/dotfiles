{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.helix;

  blame_file_pretty = pkgs.writeShellScriptBin "blame_file_pretty" ''
    # Source: https://gist.github.com/gloaysa/828707f067e3bb20da18d72fa5d4963a
    # Utility for Helix: open the patch for the commit that last touched the current line.
    # If the line isn’t committed yet, it shows the working-tree diff for THIS file only.
    # The script writes the diff to /tmp and prints the absolute path to stdout
    # Adjust `context` to see more/fewer unchanged lines around the change (default: 3).
    #
    # usage: git-file_pretty.sh <file> <line> [context_lines]
    # Helix mapping example:
    # B = ':open %sh{ ~/.config/helix/utils/git-blame-commit.sh "%{buffer_name}" %{cursor_line} 3 }'
    file="$1"
    line="$2"
    ctx="''${3:-3}"

    # blame the exact line
    porc="$(git blame -L "$line",+1 --porcelain -- "$file")" || exit 1
    sha="$(printf '%s\n' "$porc" | awk 'NR==1{print $1}')"
    commit_path="$(printf '%s\n' "$porc" | awk '/^filename /{print substr($0,10); exit}')"

    out="/tmp/hx-blame_$(basename "$file")_''${sha:-wt}.diff"

    if [ -z "$sha" ] || [ "$sha" = 0000000000000000000000000000000000000000 ] || [ "$sha" = "^" ]; then
      # uncommitted line → working tree diff for this file
      git --no-pager diff --no-color -U"$ctx" -- "$file" > "$out"
    else
      # committed line → only this file’s patch in that commit
      git --no-pager show --no-color -M -C -U"$ctx" "$sha" -- "''${commit_path:-$file}" > "$out"
    fi

    # "return" the path for :open %sh{…}
    printf '%s' "$out"
  '';

  blame_line_pretty = pkgs.writeShellScriptBin "blame_line_pretty" ''
    # Source: https://gist.github.com/gloaysa/828707f067e3bb20da18d72fa5d4963a
    # Utility for Helix: pretty-print blame info for the line under the cursor.
    # Quite basic.
    #
    # usage: blame_line_pretty <file> <line>
    # Helix mapping example:
    # b = ":run-shell-command ~/.config/helix/utils/blame_line_pretty.sh %{buffer_name} %{cursor_line}"
      file="$1"; line="$2"
      out="$(git blame -L "$line",+1 --porcelain -- "$file")" || return 1

      sha="$(printf '%s\n' "$out" | awk 'NR==1{print $1}')"
      author="$(printf '%s\n' "$out" | awk -F'author ' '/^author /{print $2; exit}')"
      epoch="$(printf '%s\n' "$out" | awk '/^author-time /{print $2; exit}')"
      # dd-mm-yyyy (macOS `date -r`; fallback to gdate if present)
      date="$( (date -r "$epoch" +%d-%m-%Y\ %H:%M 2>/dev/null) || (gdate -d "@$epoch" +%d-%m-%Y\ %H:%M 2>/dev/null) || printf '%s' "$epoch")"
      summary="$(printf '%s\n' "$out" | awk -F'summary ' '/^summary /{print $2; exit}')"
      change="$(printf '%s\n' "$out" | tail -n 1)"

      printf "%s\n%s\n%s\n%s\n%s\n" "$sha" "$author" "$date" "$summary" "$change"
  '';

in

{

  options.nmasur.presets.programs.helix.enable = lib.mkEnableOption "Helix text editor";

  config = lib.mkIf cfg.enable {

    # Use Neovim as the editor for git commit messages
    programs.git.settings.core.editor = lib.mkForce "${lib.getExe pkgs.helix}";
    programs.jujutsu.settings.ui.editor = lib.mkForce "${lib.getExe pkgs.helix}";

    # Set Neovim as the default app for text editing and manual pages
    home.sessionVariables = {
      EDITOR = lib.mkForce "${lib.getExe pkgs.helix}";
      # MANPAGER = lib.mkForce "sh -c 'col -bx | ${lib.getExe pkgs.helix}'";
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

        language-server.rumdl = {
          command = lib.getExe pkgs.rumdl;
          args = [ "server" ];
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
            language-servers = [
              "marksman"
              "rumdl"
            ];
            formatter = {
              command = lib.getExe pkgs.rumdl;
              args = [
                "fmt"
                "-"
              ];
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
            name = "terraform";
            scope = "source.tf";
            auto-format = true;
            language-servers = [ "terraform-ls" ];
            file-types = [
              "tf"
              "tfvars"
            ];
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
            file-types = [ "hcl" ];
            formatter = {
              command = "${pkgs.packer}/bin/packer";
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
          # space.B = ":echo %sh{git log -n1 --date=short --pretty=format:'%%h %%ad %%s' $(git blame -L %{cursor_line},+1 \"%{buffer_name}\" | cut -d' ' -f1)}";
          space.B = '':open %sh{ ${blame_line_pretty}/bin/blame_line_pretty "%{buffer_name}" %{cursor_line} 3 }'';
          space.i = '':open %sh{ ${blame_file_pretty}/bin/blame_file_pretty "%{buffer_name}" %{cursor_line} 3 }'';

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

          completion-replace = true; # Replace whole word with completion
          trim-trailing-whitespace = true;
          # rainbow-brackets = true; # Make it easier to match parentheses

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
