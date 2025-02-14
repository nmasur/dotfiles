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
    services.prometheus.exporters.zfs.enable = config.prometheus.exporters.enable;
    prometheus.scrapeTargets = [
      "127.0.0.1:${builtins.toString config.services.prometheus.exporters.zfs.port}"
    ];
  };
}
