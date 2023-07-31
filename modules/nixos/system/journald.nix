{ ... }: {

  # How long to keep journalctl entries
  # This helps to make sure log disk usage doesn't grow too unwieldy
  services.journald.extraConfig = ''
    SystemMaxUse=100M
    MaxFileSec=1month
    MaxRetentionSec=2month
  '';

}
