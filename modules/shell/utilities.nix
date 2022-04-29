{ config, pkgs, ... }:

let

  ignorePatterns = ''
    !.env*
    !.github/
    !.gitignore
    !*.tfvars
    .terraform/
    .target/
    /Library/
    keybase/
    kbfs/
  '';

in {

  home.packages = with pkgs; [
    unzip
    rsync
    fzf
    ripgrep
    bat
    fd
    exa
    sd
    zoxide
    jq
    tealdeer
    gh
    direnv
    tree
    htop
    glow
  ];

  home.file = {
    ".rgignore".text = ignorePatterns;
    ".fdignore".text = ignorePatterns;
  };

}
