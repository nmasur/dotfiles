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
    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.loader.efi.canTouchEfiVariables = lib.mkForce false; # Default, conflicts with tempest
    services.amazon-ssm-agent.enable = lib.mkDefault true;
    users.users.ssm-user.extraGroups = [ "wheel" ];
    services.udisks2.enable = lib.mkForce false; # Off by default already; conflicts with gvfs for nautilus
    boot.loader.grub.device = lib.mkForce "/dev/xvda"; # Default, conflicts with tempest
    boot.loader.grub.efiSupport = lib.mkForce false; # Default, conflicts with tempest
  };
}
