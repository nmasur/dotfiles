{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.profiles.no-mitigations;
in

{

  options.nmasur.profiles.no-mitigations.enable = lib.mkEnableOption "remove Kernel CPU mitigations";

  config = lib.mkIf cfg.enable {

    # WARNING: This is not secure
    boot.kernelParams = [ "mitigations=off" ];
  };
}
