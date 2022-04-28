{ config, pkgs, ... }: {

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
      reb =
        "nixos-rebuild switch -I nixos-config=${config.nixos_config}/configuration.nix";

      # Tmux
      ta = "tmux attach-session";
      tan = "tmux attach-session -t noah";
      tnn = "tmux new-session -s noah";

      # Git
      g = "git";
      gs = "git status";
      gd = "git diff";
      gds = "git diff --staged";
      gdp = "git diff HEAD^";
      ga = "git add";
      gaa = "git add -A";
      gac = "git commit -am";
      gc = "git commit -m";
      gca = "git commit --amend --no-edit";
      gcae = "git commit --amend";
      gu = "git pull";
      gp = "git push";
      gpp = "git_set_upstream";
      gl = "git log --graph --decorate --oneline -20";
      gll = "git log --graph --decorate --oneline";
      gco = "git checkout";
      gcom = "git switch master";
      gcob = "git switch -c";
      gb = "git branch";
      gbd = "git branch -d";
      gbD = "git branch -D";
      gr = "git reset";
      grh = "git reset --hard";
      gm = "git merge";
      gcp = "git cherry-pick";
      cdg = "cd (git rev-parse --show-toplevel)";

      # GitHub
      ghr = "gh repo view -w";
      gha =
        "gh run list | head -1 | awk '{ print $(NF-2) }' | xargs gh run view";
      grw = "gh run watch";
      grf = "gh run view --log-failed";
      grl = "gh run view --log";

      # Vim
      v = "vim";
      vl = "vim -c 'normal! `0'";
      vll = "vim -c 'Telescope oldfiles'";
      vimrc = "vim ${config.dotfiles}/nvim.configlink/init.lua";

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
}
