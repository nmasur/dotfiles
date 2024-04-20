{
  config,
  pkgs,
  lib,
  ...
}:
{

  options.gaming.chiaki.enable = lib.mkEnableOption "Chiaki PlayStation remote play client.";

  config = lib.mkIf config.gaming.chiaki.enable {
    environment.systemPackages = with pkgs; [ chiaki ];
  };
}
