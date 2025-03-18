{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.fish;
in

{

  options.nmasur.presets.programs.fish = {
    enable = lib.mkEnableOption "Fish shell";
    fish_user_key_bindings = lib.mkOption {
      type = lib.types.lines;
      description = "Text of fish_user_key_bindings function";
      default = "";
    };
  };

  config = lib.mkIf cfg.enable {

    nmasur.presets.programs.fish.fish_user_key_bindings = # fish
      ''
        for mode in insert default visual
            # Shift-Enter (defined by terminal)
            bind -M $mode \x1F accept-autosuggestion
            # Ctrl-f to accept auto-suggestions
            bind -M $mode \cf forward-char
        end
      '';

    programs.fish = {
      enable = true;
      functions = {
        copy = {
          description = "Copy file contents into clipboard";
          body = "cat $argv | pbcopy"; # Need to fix for non-macOS
        };
        envs = {
          description = "Evaluate a bash-like environment variables file";
          body = ''set -gx (cat $argv | tr "=" " " | string split ' ')'';
        };
        fish_user_key_bindings = {
          body = cfg.fish_user_key_bindings;
        };
        ip = {
          body = lib.getExe pkgs.nmasur.ip-check;
        };
        json = {
          description = "Tidy up JSON using jq";
          body = "pbpaste | jq '.' | pbcopy"; # Need to fix for non-macOS
        };
        _which = {
          description = "Identify the path to a program in the shell";
          body = "command --search (string sub --start=2 $argv)";
        };
      };
      interactiveShellInit = ''
        fish_vi_key_bindings
        bind yy fish_clipboard_copy
        bind Y fish_clipboard_copy
        bind -M visual y fish_clipboard_copy
        bind -M default p fish_clipboard_paste
        set -g fish_vi_force_cursor
        set -g fish_cursor_default block
        set -g fish_cursor_insert line
        set -g fish_cursor_visual block
        set -g fish_cursor_replace_one underscore
      '';
      loginShellInit = "";
      shellAbbrs = {

        # Directory aliases
        l = "ls -lh";
        lh = "ls -lh";
        ll = "ls -alhF";
        la = "ls -a";
        c = "cd";
        "-" = "cd -";
        mkd = "mkdir -pv";

        # Convert a program into its full path
        "=" = {
          position = "anywhere";
          regex = "=\\w+";
          function = "_which";
        };

        # System
        s = "sudo";
        sc = "systemctl";
        scs = "systemctl status";
        sca = "systemctl cat";
        m = "make";

        # Vim (overwritten by Neovim)
        v = "vim";
        vl = "vim -c 'normal! `0'";

        # Notes
        sn = "syncnotes";

        # Cheat Sheets
        ssl = "openssl req -new -newkey rsa:2048 -nodes -keyout server.key -out server.csr";
        fingerprint = "ssh-keyscan myhost.com | ssh-keygen -lf -";
        publickey = "ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub";
        forloop = "for i in (seq 1 100)";

        # Docker
        dc = "$DOTS/bin/docker_cleanup";
        dr = "docker run --rm -it";
        db = "docker build . -t";
      };
      shellInit = "";
    };

    home.sessionVariables.fish_greeting = "";

  };
}
