{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.starship;
in

{

  options.nmasur.presets.programs.starship.enable = lib.mkEnableOption "Starship shell prompt";

  config = lib.mkIf cfg.enable {

    home.packages = [ pkgs.jj-starship ];

    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      enableTransience = true; # Replace previous prompts with custom string
      settings = {
        add_newline = false; # Don't print new line at the start of the prompt
        format = lib.concatStrings [
          "$directory"
          "$git_branch"
          "$git_commit"
          "$git_status"
          "\${custom.jj}"
          "$hostname"
          "$cmd_duration"
          "$character"
        ];
        right_format = "$nix_shell";
        character = {
          success_symbol = "[❯](bold green)";
          error_symbol = "[❯](bold red)";
          vicmd_symbol = "[❮](bold green)";
        };
        cmd_duration = {
          min_time = 5001;
          # Must stay off. On macOS the notification blocks the prompt for ~2s,
          # and fish's $CMD_DURATION keeps its value until the next command
          # actually runs. So after any long command (every TUI session),
          # every prompt redraw -- Enter on an empty line, vi mode switches,
          # repaints -- re-sent the notification and froze the shell for 2s.
          # That was the "post-TUI typing lag" (see docs/CHANGELOG.md).
          show_notifications = false;
          format = "[$duration]($style) ";
        };
        custom = {
          jj = {
            when = "jj-starship detect";
            shell = [
              "jj-starship"
              "--no-jj-prefix"
              "--no-git-prefix"
            ];
            format = "$output ";
          };
        };
        directory = {
          truncate_to_repo = true;
          truncation_length = 100;
        };
        git_branch = {
          disabled = true;
          format = "[$symbol$branch]($style)";
        };
        git_commit = {
          disabled = true;
          format = "( @ [$hash]($style) )";
          only_detached = false;
        };
        git_status = {
          disabled = true;
          format = "([$all_status$ahead_behind]($style) )";
          conflicted = "=";
          ahead = "⇡";
          behind = "⇣";
          diverged = "⇕";
          untracked = "⋄";
          stashed = "⩮";
          modified = "∽";
          staged = "+";
          renamed = "»";
          deleted = "✘";
          style = "red";
        };
        hostname = {
          ssh_only = true;
          format = "on [$hostname](bold red) ";
        };
        nix_shell = {
          format = "[$symbol $name]($style)";
          symbol = "❄️";
        };
        python = {
          format = "[\${version}\\(\${virtualenv}\\)]($style)";
        };
      };
    };
    programs.fish = {
      functions = {
        # Adjust the prompt in previous commands
        starship_transient_prompt_func = {
          body = "echo '$ '";
        };
        starship_transient_rprompt_func = {
          body = "echo ' '";
        };
      };
    };

  };
}
