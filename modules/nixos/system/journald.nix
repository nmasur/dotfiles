{ ... }: {

  # How long to keep journalctl entries
  services.journald.extraConfig = ''
    SystemMaxUse=100M
    MaxFileSec=1month
    MaxRetentionSec=2month
  '';

}
