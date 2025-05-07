{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.services.pipewire;
in

{

  options.nmasur.presets.services.pipewire.enable = lib.mkEnableOption "Pipewire audio system";

  config = lib.mkIf cfg.enable {

    # Enable PipeWire
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };

    # Provides audio source with background noise filtered
    programs.noisetorch.enable = true;

    # These aren't necessary, but helpful for the user
    environment.systemPackages = with pkgs; [
      pamixer # Audio control
      nmasur.volnoti # Volume notifications
    ];
  };
}
