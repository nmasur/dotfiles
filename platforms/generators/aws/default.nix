{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.aws;
in
{

  options.aws.enable = lib.mkEnableOption "AWS EC2";

  config = lib.mkIf cfg.enable {

    nmasur.presets.services.openssh-aws.enable = lib.mkDefault true;

    # Make sure disk size is large enough
    # https://github.com/nix-community/nixos-generators/issues/150
    virtualisation.diskSize = lib.mkDefault (16 * 1024); # In MB

    boot.kernelPackages = lib.mkDefault pkgs.linuxKernel.packages.linux_6_6;
    boot.loader.systemd-boot.enable = false;
    boot.loader.efi.canTouchEfiVariables = false;
    services.amazon-ssm-agent.enable = lib.mkDefault true;
    users.users.ssm-user.extraGroups = [ "wheel" ];

  };
}
