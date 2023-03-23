{ config, pkgs, lib, ... }:

{

  home-manager.users.${config.user} = lib.mkIf pkgs.stdenv.isDarwin {

    home.packages = with pkgs; [
      # visidata # CSV inspector
      dos2unix # Convert Windows text files
      inetutils # Includes telnet
      youtube-dl # Convert web videos
      pandoc # Convert text documents
      mpd # TUI slideshows
      awscli2
      awslogs
      google-cloud-sdk
      ansible
      vault
      consul
      noti # Create notifications programmatically
      ipcalc # Make IP network calculations
      (pkgs.extraLib.mkScript {
        name = "ocr";
        file = ../../modules/common/shell/bash/scripts/ocr.sh;
        env = [ tesseract ];
      })
    ];

    programs.fish.shellAbbrs = {
      # Add noti for ghpr in Darwin
      ghpr = lib.mkForce "gh pr create && sleep 3 && noti gh run watch";
      grw = lib.mkForce "noti gh run watch";

      # Shortcut to edit hosts file
      hosts = "sudo nvim /etc/hosts";
    };

  };

}
