{ config, pkgs, ... }: {

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

}
