{ pkgs, user, ... }:

let

  ignorePatterns = ''
    !.env*
    !.github/
    !.gitignore
    !*.tfvars
    .terraform/
    .target/
    /Library/'';

in {

  home-manager.users.${user}.home = {

    packages = with pkgs; [
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

    file = {
      ".rgignore".text = ignorePatterns;
      ".fdignore".text = ignorePatterns;
    };

  };

}
