{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.git;
in

{

  options.nmasur.presets.programs.git = {
    enable = lib.mkEnableOption "Git version control";
    name = lib.mkOption {
      type = lib.types.str;
      description = "Name to use for git commits";
      default = config.nmasur.settings.fullName;
    };
    email = lib.mkOption {
      type = lib.types.str;
      description = "Email to use for git commits";
      default = "7386960+nmasur@users.noreply.github.com";
    };
  };

  config = lib.mkIf cfg.enable {

    programs.git = {
      enable = true;
      settings = {
        user = {
          name = cfg.name;
          email = cfg.email;
        };
        core.pager = "${pkgs.git}/share/git/contrib/diff-highlight/diff-highlight | less --no-init";
        interactive.difffilter = "${pkgs.git}/share/git/contrib/diff-highlight/diff-highlight";
        pager = {
          branch = "false";
        };
        pull = {
          ff = "only";
        };
        push = {
          autoSetupRemote = "true";
        };
        init = {
          defaultBranch = "master";
        };
        rebase = {
          autosquash = "true";
        };
        gpg = {
          format = "ssh";
          ssh.allowedSignersFile = "~/.config/git/allowed-signers";
        };
        # commit.gpgsign = true;
        # tag.gpgsign = true;
      };
      ignores = [
        ".direnv/**"
        "result"
      ];
    };

    xdg.configFile."git/allowed-signers".text = ''
      7386960+nmasur@users.noreply.github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB+AbmjGEwITk5CK9y7+Rg27Fokgj9QEjgc9wST6MA3s
    '';

    programs.fish.shellAbbrs = {
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
      gl = "git log --graph --decorate --oneline -20";
      gll = "git log --graph --decorate --oneline";
      gco = "git checkout";
      gcom = ''git switch (git symbolic-ref refs/remotes/origin/HEAD | cut -d"/" -f4)'';
      gcob = "git switch -c";
      gb = "git branch";
      gpd = "git push origin -d";
      gbd = "git branch -d";
      gbD = "git branch -D";
      gdd = {
        position = "anywhere";
        setCursor = true;
        expansion = "BRANCH=% git push origin -d $BRANCH and git branch -d $BRANCH";
      };
      gr = "git reset";
      grh = "git reset --hard";
      gm = "git merge";
      gcp = "git cherry-pick";
      cdg = "cd (git rev-parse --show-toplevel)";
    };

    # Required for fish commands
    home.packages = with pkgs; [
      fish
      fzf
      bat
    ];

    programs.fish.functions = {
      git = {
        body = builtins.readFile ./fish/git.fish;
      };
      git-add-fuzzy = {
        body = builtins.readFile ./fish/git-add-fuzzy.fish;
      };
      git-fuzzy-branch = {
        argumentNames = "header";
        body = builtins.readFile ./fish/git-fuzzy-branch.fish;
      };
      git-checkout-fuzzy = {
        body = ''
          set branch (git-fuzzy-branch "checkout branch...")
          and git checkout $branch
        '';
      };
      git-delete-fuzzy = {
        body = ''
          set branch (git-fuzzy-branch "delete branch...")
          and git branch -d $branch
        '';
      };
      git-force-delete-fuzzy = {
        body = ''
          set branch (git-fuzzy-branch "force delete branch...")
          and git branch -D $branch
        '';
      };
      git-delete-both = {
        argumentNames = "branch";
        body = ''
          git push origin -d $branch
          git branch -d $branch
        '';
      };
      git-merge-fuzzy = {
        body = ''
          set branch (git-fuzzy-branch "merge from...")
          and git merge $branch
        '';
      };
      git-show-fuzzy = {
        body = builtins.readFile ./fish/git-show-fuzzy.fish;
      };
      git-commits = {
        body = builtins.readFile ./fish/git-commits.fish;
      };
      commandline-git-commits = {
        description = "Insert commit into commandline";
        body = builtins.readFile ./fish/commandline-git-commits.fish;
      };
      git-history = {
        body = builtins.readFile ./fish/git-history.fish;
      };
      uncommitted = {
        description = "Find uncommitted git repos";
        body = builtins.readFile ./fish/uncommitted.fish;
      };
    };

    nmasur.presets.programs.fish.fish_user_key_bindings = # fish
      ''
        # Ctrl-g
        bind -M default \cg commandline-git-commits
        bind -M insert \cg 'commandline -i (git rev-parse --show-toplevel 2>/dev/null || echo ".")'
      '';

  };
}
