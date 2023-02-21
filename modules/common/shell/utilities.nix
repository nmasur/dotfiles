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

      # Fix: age won't build
      nixpkgs.overlays = [
        (_final: prev: {
          age = prev.age.overrideAttrs (_old: {
            src = prev.fetchFromGitHub {
              owner = "FiloSottile";
              repo = "age";
              rev = "7354aa0d08a06eac42c635670a55f858bd23c943";
              sha256 = "H80mNTgZmExDMgubONIXP7jmLBvNMVqXee6NiZJhPFY=";
            };
          });
        })
      ];

      home.packages = with pkgs; [
        unzip # Extract zips
        rsync # Copy folders
        ripgrep # grep
        fd # find
        sd # sed
        jq # JSON manipulation
        tealdeer # Cheatsheets
        tree # View directory hierarchy
        htop # Show system processes
        qrencode # Generate qr codes
        vimv-rs # Batch rename files
        dig # DNS lookup
        lf # File viewer
        inetutils # Includes telnet, whois
        age # Encryption
      ];

      programs.zoxide.enable = true; # Shortcut jump command

      home.file = {
        ".rgignore".text = ignorePatterns;
        ".fdignore".text = ignorePatterns;
        ".digrc".text = "+noall +answer"; # Cleaner dig commands
      };

      programs.bat = {
        enable = true; # cat replacement
        config = { theme = config.theme.colors.batTheme; };
      };

      programs.fish.shellAbbrs = {
        cat = "bat"; # Swap cat with bat
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
