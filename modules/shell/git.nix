{ config, pkgs, lib, identity, ... }:

let home-packages = config.home-manager.users.${identity.user}.home.packages;

in {

  home-manager.users.${identity.user} = {
    programs.git = {
      enable = true;
      userName = identity.name;
      userEmail = identity.gitEmail;
      extraConfig = {
        pager = { branch = "false"; };
        safe = { directory = builtins.toString ../../.; };
        pull = { ff = "only"; };
      };
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
    };

    programs.fish.functions = lib.mkIf (builtins.elem pkgs.fzf home-packages
      && builtins.elem pkgs.bat home-packages) {
        git = {
          body = builtins.readFile ../../fish.configlink/functions/git.fish;
        };
        git-add-fuzzy = {
          body = builtins.readFile
            ../../fish.configlink/functions/git-add-fuzzy.fish;
        };
        git-fuzzy-branch = {
          argumentNames = "header";
          body = builtins.readFile
            ../../fish.configlink/functions/git-fuzzy-branch.fish;
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
          body = builtins.readFile
            ../../fish.configlink/functions/git-show-fuzzy.fish;
        };
        git-commits = {
          body =
            builtins.readFile ../../fish.configlink/functions/git-commits.fish;
        };
        git-history = {
          body =
            builtins.readFile ../../fish.configlink/functions/git-history.fish;
        };
        git-push-upstream = {
          description = "Create upstream branch";
          body = builtins.readFile
            ../../fish.configlink/functions/git-push-upstream.fish;
        };
        uncommitted = {
          description = "Find uncommitted git repos";
          body =
            builtins.readFile ../../fish.configlink/functions/uncommitted.fish;
        };
      };
  };

}
