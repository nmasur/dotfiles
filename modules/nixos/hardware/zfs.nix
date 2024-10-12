{
  config,
  pkgs,
  lib,
  ...
}:
{

  options = {
    zfs.enable = lib.mkEnableOption "ZFS file system.";
  };

  config = lib.mkIf (config.server && config.zfs.enable) {

    # Only use compatible Linux kernel, since ZFS can be behind
    boot.kernelPackages = pkgs.linuxPackages; # Defaults to latest LTS
    boot.kernelParams = [ "nohibernate" ];
    boot.supportedFilesystems = [ "zfs" ];
    services.prometheus.exporters.zfs.enable = config.prometheus.exporters.enable;
    prometheus.scrapeTargets = [
      "127.0.0.1:${builtins.toString config.services.prometheus.exporters.zfs.port}"
    ];
  };
}
