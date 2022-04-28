{ config, pkgs, ... }: {

  programs.git = {
    enable = true;
    userName = "${config.fullName}";
    userEmail = "7386960+nmasur@users.noreply.github.com";
    extraConfig = {
      pager = { branch = "false"; };
      safe = { directory = "${config.dotfiles}"; };
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
  };

}
