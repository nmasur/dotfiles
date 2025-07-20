{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.slsk-batchdl;
in

{

  options.nmasur.presets.programs.slsk-batchdl.enable = lib.mkEnableOption "slsk downloader";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.nmasur.slsk-batchdl
    ];
  };
}
