{ config, pkgs, ... }: {

  home-manager.users.${config.user} = {

    home.packages = [
      visidata # CSV inspector
      dos2unix # Convert Windows text files
      inetutils # Includes telnet
      youtube-dl # Convert web videos
      pandoc # Convert text documents
      mpd # TUI slideshows
      awscli2
      awslogs
      kubectl
      k9s
      noti # Create notifications programmatically
    ];

    programs.alacritty.settings = {
      shell.program = "${pkgs.fish}/bin/fish";
      keybindings = [
        {
          key = "F";
          mods = "Super";
          action = "ToggleSimpleFullscreen";
        }
        {
          key = "L";
          mods = "Super";
          chars = "\\x1F";
        }
      ];
    };

    fonts.fonts = with pkgs;
      [ (nerdfonts.override { fonts = [ "fira-mono" ]; }) ];

    xdg.configFile.hammerspoon = { source = ./hammerspoon; };

    programs.fish = {
      shellAbbrs = {
        nr =
          "sudo darwin-rebuild switch --flake ${config.dotfilesPath}#macbook";
      };
    };

  };

  system.activationScripts.hammerspoon.text = ''
    defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"
  '';

}
