{
  config,
  pkgs,
  lib,
  ...
}:

{

  unfreePackages = [
    "consul"
    "vault-bin"
    "teams"
  ];

  home-manager.users.${config.user} = lib.mkIf pkgs.stdenv.isDarwin {

    home.packages = [
      pkgs.visidata # CSV inspector
      pkgs.dos2unix # Convert Windows text files
      pkgs.inetutils # Includes telnet
      pkgs.pandoc # Convert text documents
      pkgs.mpd # TUI slideshows
      pkgs.mpv # Video player
      pkgs.gnupg # Encryption
      pkgs.awscli2
      pkgs.ssm-session-manager-plugin
      pkgs.awslogs
      pkgs.stu # TUI for AWS S3
      pkgs.google-cloud-sdk
      pkgs.vault-bin
      pkgs.consul
      pkgs.noti # Create notifications programmatically
      pkgs.ipcalc # Make IP network calculations
      pkgs.teams
      pkgs.cloudflared # Allow connecting to Cloudflare tunnels
      (pkgs.writeShellApplication {
        name = "ocr";
        runtimeInputs = [ pkgs.tesseract ];
        text = builtins.readFile ../../modules/common/shell/bash/scripts/ocr.sh;
      })
      (pkgs.writeShellApplication {
        name = "ec2";
        runtimeInputs = [
          pkgs.awscli2
          pkgs.jq
          pkgs.fzf
        ];
        text = builtins.readFile ../../modules/common/shell/bash/scripts/aws-ec2.sh;
      })
      (pkgs.writeShellApplication {
        name = "tfinit";
        runtimeInputs = [
          pkgs.terraform
          pkgs.gawk
          pkgs.git
        ];
        text = builtins.readFile ../../modules/common/shell/bash/scripts/terraform-init.sh;
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
