{
  config,
  pkgs,
  lib,
  ...
}:
{

  options.gaming.moonlight.enable = lib.mkEnableOption "Enable Moonlight game streaming client.";

  config = lib.mkIf config.gaming.moonlight.enable {
    environment.systemPackages = with pkgs; [ moonlight-qt ];
  };
}
