{ ... }:
{

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
}
