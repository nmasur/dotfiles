{ pkgs, user, ... }: {

  users.users.${user}.shell = pkgs.fish;

  home-manager.users.${user} = {
    programs.fish = {
      enable = true;
      functions = { };
      interactiveShellInit = "";
      loginShellInit = "";
      shellAliases = {
        vim = "nvim";
        sudo = "doas";
      };
      shellAbbrs = {

        # Directory aliases
        l = "ls";
        lh = "ls -lh";
        ll = "ls -alhF";
        la = "ls -a";
        lf = "ls -lh | fzf";
        c = "cd";
        "-" = "cd -";
        mkd = "mkdir -pv";

        # System
        s = "sudo";
        sc = "systemctl";
        scs = "systemctl status";
        reb = "nixos-rebuild switch -I nixos-config=${
            builtins.toString ../../nixos/.
          }/configuration.nix";

        # Tmux
        ta = "tmux attach-session";
        tan = "tmux attach-session -t noah";
        tnn = "tmux new-session -s noah";

        # Vim
        v = "vim";
        vl = "vim -c 'normal! `0'";
        vll = "vim -c 'Telescope oldfiles'";
        vimrc = "vim ${builtins.toString ../../.}/nvim.configlink/init.lua";

        # Notes
        qn = "quicknote";
        sn = "syncnotes";
        to = "today";
        work = "vim $NOTES_PATH/work.md";

        # CLI Tools
        cat = "bat"; # Swap cat with bat
        h = "http -Fh --all"; # Curl site for headers
        m = "make"; # For makefiles

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
      shellAliases = { };
      shellInit = "";
    };

    home.sessionVariables = { fish_greeting = ""; };

    programs.starship = {
      enable = true;
      enableFishIntegration = true;
    };

    programs.fzf = {
      enable = true;
      enableFishIntegration = true;
    };

    programs.zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    xdg.configFile = {
      "starship.toml".source = ../../starship/starship.toml.configlink;
      "fish/functions".source = ../../fish.configlink/functions;
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      config = { whitelist = { prefix = [ "${builtins.toString ../.}/" ]; }; };
    };
  };
}
