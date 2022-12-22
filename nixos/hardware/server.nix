{ config, pkgs, lib, ... }: {

  config = lib.mkIf (pkgs.stdenv.isLinux && config.server) {

    # Servers need a bootloader or they won't start
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

  };

}
