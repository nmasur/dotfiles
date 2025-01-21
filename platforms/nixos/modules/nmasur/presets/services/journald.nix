{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.services.journald;
in

{

  options.nmasur.presets.services.journald.enable = lib.mkEnableOption "journald configuration";

  config = lib.mkIf cfg.enable {
    # How long to keep journalctl entries
    # This helps to make sure log disk usage doesn't grow too unwieldy
    services.journald.extraConfig = ''
      SystemMaxUse=4G
      SystemKeepFree=10G
      SystemMaxFileSize=128M
      SystemMaxFiles=500
      MaxFileSec=1month
      MaxRetentionSec=2month
    '';
  };
}
