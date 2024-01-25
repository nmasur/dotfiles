{ config, pkgs, lib, ... }: {

  config = lib.mkIf pkgs.stdenv.isDarwin {
    networking = {
      computerName = config.networking.hostName;
      # Adjust if necessary
      # hostName = "";
    };
  };

}
