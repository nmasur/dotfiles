{ config, pkgs, lib, ... }:

{
  config = {
    services.keybase.enable = true;
    services.kbfs.enable = true;

    # home.packages = with pkgs lib; [ (mkIf config.gui keybase-gui) ];
  };
}
