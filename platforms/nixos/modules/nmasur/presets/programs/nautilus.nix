{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.nautilus;
in

{

  options.nmasur.presets.programs.nautilus.enable = lib.mkEnableOption "Nautilus file manager";

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ pkgs.nautilus ];

    # Quick preview with spacebar
    services.gnome.sushi.enable = true;

    # Allow client browsing Samba and virtual filesystem shares
    services.gvfs = {
      enable = true;
    };

  };
}
