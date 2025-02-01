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
      pkgs.ocr # Converts images to text
      pkgs.aws-ec2 # Browse EC2 instances
      pkgs.terraform-init # Quick shortcut for initializing Terraform backend
    ];

    programs.helix.enable = lib.mkDefault true;
    programs.zed-editor.enable = lib.mkDefault true;

    nmasur.presets = {
      programs = {
        _1password.enable = lib.mkDefault true;
        atuin.enable = lib.mkDefault true;
        bash.enable = lib.mkDefault true;
        bat.enable = lib.mkDefault true;
        direnv.enable = lib.mkDefault true;
        dotfiles.enable = lib.mkDefault true;
        fd.enable = lib.mkDefault true;
        firefox.enable = lib.mkDefault true;
        fish.enable = lib.mkDefault true;
        fzf.enable = lib.mkDefault true;
        git-work.enable = lib.mkDefault true;
        git.enable = lib.mkDefault true;
        github.enable = lib.mkDefault true;
        jujutsu.enable = lib.mkDefault true;
        k9s.enable = lib.mkDefault true;
        kubectl.enable = lib.mkDefault true;
        ldapsearch.enable = lib.mkDefault true;
        ripgrep.enable = lib.mkDefault true;
        starship.enable = lib.mkDefault true;
        terraform.enable = lib.mkDefault true;
        weather.enable = lib.mkDefault true;
        wezterm.enable = lib.mkDefault true;
      };
    };

  };

}
