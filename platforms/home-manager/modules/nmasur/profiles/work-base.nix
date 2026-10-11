{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.profiles.work-base;
in

{

  options.nmasur.profiles.work-base.enable = lib.mkEnableOption "base work config";

  config = lib.mkIf cfg.enable {

    home.packages = [
      pkgs.actionlint # Lint for GitHub Actions Workflows
      pkgs.claude-code # AI LLM Agent
      pkgs.stable.visidata # CSV inspector
      pkgs.dos2unix # Convert Windows text files
      pkgs.inetutils # Includes telnet
      pkgs.gnupg # Encryption
      pkgs.awscli2
      pkgs.ssm-session-manager-plugin
      pkgs.awslogs
      pkgs.pre-commit
      pkgs.google-cloud-sdk
      pkgs.ipcalc # Make IP network calculations
      pkgs.nmasur.aws-ec2 # Browse EC2 instances
      pkgs.nmasur.terraform-init # Quick shortcut for initializing Terraform backend
      pkgs.uv # Python packaging
    ];

    programs.fish.shellAliases.ec2 = "aws-ec2";

    nmasur.presets = {
      programs = {
        # _1password.enable = lib.mkDefault true;
        atuin.enable = lib.mkDefault true;
        aws-ssh.enable = lib.mkDefault true;
        bash.enable = lib.mkDefault true;
        bat.enable = lib.mkDefault true;
        direnv.enable = lib.mkDefault true;
        dotfiles.enable = lib.mkDefault true;
        fd.enable = lib.mkDefault true;
        fish.enable = lib.mkDefault true;
        fzf.enable = lib.mkDefault true;
        git-work.enable = lib.mkDefault true;
        git.enable = lib.mkDefault true;
        github.enable = lib.mkDefault true;
        jujutsu.enable = lib.mkDefault true;
        ripgrep.enable = lib.mkDefault true;
        starship.enable = lib.mkDefault true;
        terraform.enable = lib.mkDefault true;
      };
    };

  };

}
