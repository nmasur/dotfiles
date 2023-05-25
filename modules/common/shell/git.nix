{ config, pkgs, lib, ... }:

let home-packages = config.home-manager.users.${config.user}.home.packages;

in {

  options = {
    gitName = lib.mkOption {
      type = lib.types.str;
      description = "Name to use for git commits";
    };
    gitEmail = lib.mkOption {
      type = lib.types.str;
      description = "Email to use for git commits";
    };
  };

  config = {

    home-manager.users.root.programs.git = {
      enable = true;
      extraConfig.safe.directory = config.dotfilesPath;
    };

    home-manager.users.${config.user} = {
      programs.git = {
        enable = true;
        userName = config.gitName;
        userEmail = config.gitEmail;
        extraConfig = {
          pager = { branch = "false"; };
          safe = { directory = config.dotfilesPath; };
          pull = { ff = "only"; };
          push = { autoSetupRemote = "true"; };
          init = { defaultBranch = "master"; };
        };
        ignores = [ ".direnv/**" "result" ];
      };

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
        gpp = "git-push-upstream";
        gl = "git log --graph --decorate --oneline -20";
        gll = "git log --graph --decorate --oneline";
        gco = "git checkout";
        gcom = ''
          git switch (git symbolic-ref refs/remotes/origin/HEAD | cut -d"/" -f4)'';
        gcob = "git switch -c";
        gb = "git branch";
        gbd = "git branch -d";
        gbD = "git branch -D";
        gr = "git reset";
        grh = "git reset --hard";
        gm = "git merge";
        gcp = "git cherry-pick";
        cdg = "cd (git rev-parse --show-toplevel)";
      };

      # Required for fish commands
      home.packages = with pkgs; [ fish fzf bat ];

      programs.fish.functions = lib.mkIf (builtins.elem pkgs.fzf home-packages
        && builtins.elem pkgs.bat home-packages) {
          git = { body = builtins.readFile ./fish/functions/git.fish; };
          git-add-fuzzy = {
            body = builtins.readFile ./fish/functions/git-add-fuzzy.fish;
          };
          git-fuzzy-branch = {
            argumentNames = "header";
            body = builtins.readFile ./fish/functions/git-fuzzy-branch.fish;
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
          git-merge-fuzzy = {
            body = ''
              set branch (git-fuzzy-branch "merge from...")
              and git merge $branch
            '';
          };
          git-show-fuzzy = {
            body = builtins.readFile ./fish/functions/git-show-fuzzy.fish;
          };
          git-commits = {
            body = builtins.readFile ./fish/functions/git-commits.fish;
          };
          git-history = {
            body = builtins.readFile ./fish/functions/git-history.fish;
          };
          git-push-upstream = {
            description = "Create upstream branch";
            body = builtins.readFile ./fish/functions/git-push-upstream.fish;
          };
          uncommitted = {
            description = "Find uncommitted git repos";
            body = builtins.readFile ./fish/functions/uncommitted.fish;
          };
        };
    };

  };

}
