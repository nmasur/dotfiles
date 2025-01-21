{ config, ... }:

let
  cfg = config.nmasur.profiles.aws;
in
{

  options.nmasur.profiles.nmasur.aws.enable = lib.mkEnableOption "AWS EC2";

  config = lib.mkIf cfg.enable {

    # AWS settings require this
    permitRootLogin = "prohibit-password";

    # Make sure disk size is large enough
    # https://github.com/nix-community/nixos-generators/issues/150
    amazonImage.sizeMB = 16 * 1024;

  };
}
