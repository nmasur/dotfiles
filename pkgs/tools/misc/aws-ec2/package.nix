{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "aws-ec2";
  runtimeInputs = [
    pkgs.awscli2
    pkgs.jq
    pkgs.fzf
    pkgs.ssm-session-manager-plugin
  ];
  text = builtins.readFile ./aws-ec2.sh;
}
