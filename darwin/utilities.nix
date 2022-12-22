{ config, pkgs, lib, ... }:

let

  # Quickly package shell scripts with their dependencies
  # From https://discourse.nixos.org/t/how-to-create-a-script-with-dependencies/7970/6
  mkScript = { name, file, env ? [ ] }:
    pkgs.writeScriptBin name ''
      for i in ${lib.concatStringsSep " " env}; do
        export PATH="$i/bin:$PATH"
      done

      exec ${pkgs.bash}/bin/bash ${file} $@
    '';

in {

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
      (mkScript {
        name = "ocr";
        file = ../modules/shell/bash/scripts/ocr.sh;
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
