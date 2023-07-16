{ config, pkgs, lib, ... }: {

  options = { zfs.enable = lib.mkEnableOption "ZFS file system."; };

  config =
    lib.mkIf (pkgs.stdenv.isLinux && config.server && config.zfs.enable) {

      # Only use compatible Linux kernel, since ZFS can be behind
      boot.kernelPackages =
        config.boot.zfs.package.latestCompatibleLinuxPackages;
      boot.kernelParams = [ "nohibernate" ];
      boot.supportedFilesystems = [ "zfs" ];
      services.prometheus.exporters.zfs.enable = true;
      scrapeTargets = [
        "127.0.0.1:${
          builtins.toString config.services.prometheus.exporters.zfs.port
        }"
      ];

    };

}
