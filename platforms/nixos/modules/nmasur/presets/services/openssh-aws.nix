# SSHD settings for AWS machines

{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.services.openssh-aws;
in
{

  options.nmasur.presets.services.openssh-aws = {
    enable = lib.mkEnableOption "OpenSSH on AWS VMs";
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      settings = {
        # AWS settings require this
        PermitRootLogin = lib.mkForce "prohibit-password";
      };
    };

  };
}
