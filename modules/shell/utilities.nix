{ config, pkgs, ... }:

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

  home-manager.users.${config.user} = {

    home.packages = with pkgs; [
      unzip # Extract zips
      rsync # Copy folders
      ripgrep # grep
      bat # cat
      fd # find
      sd # sed
      jq # JSON manipulation
      tealdeer # Cheatsheets
      tree # View directory hierarchy
      htop # Show system processes
      glow # Pretty markdown previews
      prettyping # ping
      qrencode # Generate qr codes
      vimv # Batch rename files
      dig # DNS lookup
      # gnupg
      # pass
    ];

    home.file = {
      ".rgignore".text = ignorePatterns;
      ".fdignore".text = ignorePatterns;
      ".digrc".text = "+noall +answer"; # Cleaner dig commands
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
