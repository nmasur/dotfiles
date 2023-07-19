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

  config = {

    home-manager.users.${config.user} = {

      home.packages = with pkgs; [
        age # Encryption
        bc # Calculator
        dig # DNS lookup
        fd # find
        htop # Show system processes
        inetutils # Includes telnet, whois
        jq # JSON manipulation
        lf # File viewer
        qrencode # Generate qr codes
        rsync # Copy folders
        ripgrep # grep
        sd # sed
        tealdeer # Cheatsheets
        tree # View directory hierarchy
        vimv-rs # Batch rename files
        unzip # Extract zips
      ];

      programs.zoxide.enable = true; # Shortcut jump command

      home.file = {
        ".rgignore".text = ignorePatterns;
        ".fdignore".text = ignorePatterns;
        ".digrc".text = "+noall +answer"; # Cleaner dig commands
      };

      programs.bat = {
        enable = true; # cat replacement
        config = {
          theme = config.theme.colors.batTheme;
          pager = "less -R"; # Don't auto-exit if one screen
        };
      };

      programs.fish.functions = {
        ping = {
          description = "Improved ping";
          argumentNames = "target";
          body = "${pkgs.prettyping}/bin/prettyping --nolegend $target";
        };
      };

    };

  };

}
