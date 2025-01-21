{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.profiles.work;
in

{

  options.nmasur.profiles.work.enable = lib.mkEnableOption "work config";

  config = lib.mkIf cfg.enable {

    unfreePackages = [
      "vault-bin"
      # "teams"
    ];

    home.packages = [
      pkgs.visidata # CSV inspector
      pkgs.dos2unix # Convert Windows text files
      pkgs.inetutils # Includes telnet
      pkgs.gnupg # Encryption
      pkgs.awscli2
      pkgs.ssm-session-manager-plugin
      pkgs.awslogs
      pkgs.stu # TUI for AWS S3
      pkgs.google-cloud-sdk
      pkgs.vault-bin
      pkgs.ipcalc # Make IP network calculations
      pkgs.cloudflared # Allow connecting to Cloudflare tunnels
      pkgs.monitorcontrol # Allows adjusting external displays
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
  };

}
