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

    # AWS settings require this
    permitRootLogin = "prohibit-password";

    # Make sure disk size is large enough
    # https://github.com/nix-community/nixos-generators/issues/150
    amazonImage.sizeMB = 16 * 1024;

    boot.kernelPackages = pkgs.legacyPackages.x86_64-linux.linuxKernel.packages.linux_6_6;
    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
    services.amazon-ssm-agent.enable = true;
    users.users.ssm-user.extraGroups = [ "wheel" ];

  };
}
