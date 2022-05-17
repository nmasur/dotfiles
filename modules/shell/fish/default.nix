{ config, pkgs, lib, ... }: {

  users.users.${config.user}.shell = pkgs.fish;

  home-manager.users.${config.user} = {

    home.packages = with pkgs; [ curl ];

    programs.fish = {
      enable = true;
      functions = {
        commandline-git-commits = {
          description = "Insert commit into commandline";
          body = builtins.readFile ./functions/commandline-git-commits.fish;
        };
        copy = {
          description = "Copy file contents into clipboard";
          body = "cat $argv | pbcopy"; # Need to fix for non-macOS
        };
        edit = {
          description = "Open a file in Vim";
          body = builtins.readFile ./functions/edit.fish;
        };
        envs = {
          description = "Evaluate a bash-like environment variables file";
          body = ''set -gx (cat $argv | tr "=" " " | string split ' ')'';
        };
        fcd = {
          description = "Jump to directory";
          argumentNames = "directory";
          body = builtins.readFile ./functions/fcd.fish;
        };
        fish_user_key_bindings = {
          body = builtins.readFile ./functions/fish_user_key_bindings.fish;
        };
        ip = { body = builtins.readFile ./functions/ip.fish; };
        json = {
          description = "Tidy up JSON using jq";
          body = "pbpaste | jq '.' | pbcopy"; # Need to fix for non-macOS
        };
        ls = { body = "${pkgs.exa}/bin/pkgs $argv"; };
        note = {
          description = "Edit or create a note";
          argumentNames = "filename";
          body = builtins.readFile ./functions/note.fish;
        };
        recent = {
          description = "Open a recent file in Vim";
          body = builtins.readFile ./functions/recent.fish;
        };
        syncnotes = {
          description = "Full git commit on notes";
          body = builtins.readFile ./functions/syncnotes.fish;
        };
      };
      interactiveShellInit = ''
        bind yy fish_clipboard_copy
        bind Y fish_clipboard_copy
        bind -M visual y fish_clipboard_copy
        bind p fish_clipboard_paste
        set -g fish_vi_force_cursor
        set -g fish_cursor_default block
        set -g fish_cursor_insert line
        set -g fish_cursor_visual block
        set -g fish_cursor_replace_one underscore
      '';
      loginShellInit = "";
      shellAliases = { };
      shellAbbrs = {

        # Directory aliases
        l = "ls -lh";
        lh = "ls -lh";
        ll = "ls -alhF";
        la = "ls -a";
        c = "cd";
        "-" = "cd -";
        mkd = "mkdir -pv";

        # System
        s = "sudo";
        sc = "systemctl";
        scs = "systemctl status";
        m = "make";

        # Tmux
        ta = "tmux attach-session";
        tan = "tmux attach-session -t noah";
        tnn = "tmux new-session -s noah";

        # Vim
        v = "vim";
        vl = "vim -c 'normal! `0'";

        # Notes
        sn = "syncnotes";

        # Fun CLI Tools
        weather = "curl wttr.in/$WEATHER_CITY";
        moon = "curl wttr.in/Moon";

        # Cheat Sheets
        ssl =
          "openssl req -new -newkey rsa:2048 -nodes -keyout server.key -out server.csr";
        fingerprint = "ssh-keyscan myhost.com | ssh-keygen -lf -";
        publickey = "ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub";
        forloop = "for i in (seq 1 100)";

        # Docker
        dc = "$DOTS/bin/docker_cleanup";
        dr = "docker run --rm -it";
        db = "docker build . -t";

        # Terraform
        te = "terraform";

        # Kubernetes
        k = "kubectl";
        pods = "kubectl get pods -A";
        nodes = "kubectl get nodes";
        deploys = "kubectl get deployments -A";
        dash = "kube-dashboard";
        ks = "k9s";

        # Python
        py = "python";
        po = "poetry";
        pr = "poetry run python";

        # Rust
        ca = "cargo";

      };
      shellInit = "";
    };

    home.sessionVariables.fish_greeting = "";

    programs.starship.enableFishIntegration = true;
    programs.zoxide.enableFishIntegration = true;
    programs.fzf.enableFishIntegration = true;

    # Provides "command-not-found" options
    # Requires activating a manual download
    programs.nix-index = {
      enable = true;
      enableFishIntegration = true;
    };

  };
}
