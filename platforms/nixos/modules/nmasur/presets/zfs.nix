{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.zfs;
in

{

  options.nmasur.presets.zfs.enable = lib.mkEnableOption "ZFS file system";

  config = lib.mkIf cfg.enable {

    # Only use compatible Linux kernel, since ZFS can be behind
    boot.kernelPackages = pkgs.linuxPackages; # Defaults to latest LTS
    boot.kernelParams = [ "nohibernate" ]; # ZFS does not work with hibernation
    boot.supportedFilesystems = [ "zfs" ];
    services.prometheus.exporters.zfs.enable = true;
    nmasur.presets.services.prometheus-exporters.scrapeTargets = [
      "127.0.0.1:${builtins.toString config.services.prometheus.exporters.zfs.port}"
    ];

    zramSwap.enable = true;
    swapDevices = [
      {
        device = "/swapfile";
        size = 4 * 1024; # 4 GB
      }
    ];

    boot.zfs = {
      # Automatically load the ZFS pool on boot
      extraPools = [ "tank" ];
      # Only try to decrypt datasets with keyfiles
      requestEncryptionCredentials = [
        "tank/archive"
        "tank/generic"
        "tank/nextcloud"
        "tank/generic/git"
        "tank/images"
      ];
      # If password is requested and fails, continue to boot eventually
      passwordTimeout = 300;
    };

  };
}
