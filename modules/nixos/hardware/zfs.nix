{ config, pkgs, lib, ... }: {

  options = { zfs.enable = lib.mkEnableOption "ZFS file system."; };

  config =
    lib.mkIf (pkgs.stdenv.isLinux && config.server && config.zfs.enable) {

      # Only use compatible Linux kernel, since ZFS can be behind
      boot.kernelPackages =
        config.boot.zfs.package.latestCompatibleLinuxPackages;

    };

}
