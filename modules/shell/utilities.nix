{ pkgs, identity, ... }:

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

  home-manager.users.${identity.user} = {

    home.packages = with pkgs; [
      unzip
      rsync
      ripgrep
      bat
      fd
      sd
      jq
      tealdeer
      tree
      htop
      glow
      prettyping
      qrencode
    ];

    home.file = {
      ".rgignore".text = ignorePatterns;
      ".fdignore".text = ignorePatterns;
    };

    programs.fish.shellAbbrs = {
      cat = "bat"; # Swap cat with bat
    };

    programs.fish.functions = {
      ping = {
        description = "Improved ping";
        argumentNames = "target";
        body = "prettyping --nolegend $target";
      };
      qr = {
        body =
          "qrencode $argv[1] -o /tmp/qr.png | open /tmp/qr.png"; # Fix for non-macOS
      };
    };

  };

}
