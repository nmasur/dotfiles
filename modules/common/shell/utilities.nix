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
in
{

  config = {

    home-manager.users.${config.user} = {

      home.packages = with pkgs; [
        age # Encryption
        bc # Calculator
        delta # Fancy diffs
        difftastic # Other fancy diffs
        dig # DNS lookup
        fd # find
        htop # Show system processes
        killall # Force quit
        inetutils # Includes telnet, whois
        jless # JSON viewer
        jo # JSON output
        jq # JSON manipulation
        lf # File viewer
        qrencode # Generate qr codes
        rsync # Copy folders
        ren # Rename files
        # rep # Replace text in files
        ripgrep # grep
        sd # sed
        tealdeer # Cheatsheets
        tree # View directory hierarchy
        vimv-rs # Batch rename files
        unzip # Extract zips
        dua # File sizes (du)
        du-dust # Disk usage tree (ncdu)
        duf # Basic disk information (df)
      ];

      programs.zoxide.enable = true; # Shortcut jump command

      home.file = {
        ".rgignore".text = ignorePatterns;
        ".digrc".text = "+noall +answer"; # Cleaner dig commands
      };

      xdg.configFile."fd/ignore".text = ignorePatterns;

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
