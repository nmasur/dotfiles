{ config, pkgs, lib, ... }: {

  home-manager.users.${config.user} = {

    home.packages = with pkgs; [
      # visidata # CSV inspector
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
      ipcalc
      (pkgs.writeScriptBin "ocr"
        (builtins.readFile ../shell/bash/scripts/ocr.sh))
    ];

    programs.fish.shellAbbrs = {
      # Add noti for ghpr in Darwin
      ghpr = lib.mkForce "gh pr create && sleep 3 && noti gh run watch";

      # Shortcut to edit hosts file
      hosts = "sudo nvim /etc/hosts";
    };

  };

}
