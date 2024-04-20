{
  config,
  pkgs,
  lib,
  ...
}:
{

  options.gaming.lutris.enable = lib.mkEnableOption "Lutris game installer.";

  config = lib.mkIf config.gaming.lutris.enable {
    environment.systemPackages = with pkgs; [
      lutris
      amdvlk # Vulkan drivers (probably already installed)
      wineWowPackages.stable # 32-bit and 64-bit wineWowPackages
    ];
  };
}
