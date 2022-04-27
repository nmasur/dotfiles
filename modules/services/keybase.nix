{ config, pkgs, lib, ... }:

let gui = config.gui;

in {

  config = {
    services.keybase.enable = true;
    services.kbfs.enable = true;

    # home.packages = with lib; with pkgs; [ (mkIf gui.enable keybase-gui) ];
  };
}
