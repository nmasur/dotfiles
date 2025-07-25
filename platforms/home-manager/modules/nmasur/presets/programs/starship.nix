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
          min_time = 5000;
          show_notifications = if pkgs.stdenv.isLinux then false else true;
          min_time_to_notify = 30000;
          format = "[$duration]($style) ";
        };
        directory = {
          truncate_to_repo = true;
          truncation_length = 100;
        };
        git_branch = {
          format = "[$symbol$branch]($style)";
        };
        git_commit = {
          format = "( @ [$hash]($style) )";
          only_detached = false;
        };
        git_status = {
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
