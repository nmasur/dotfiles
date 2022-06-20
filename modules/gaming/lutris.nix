{ config, pkgs, lib, ... }: {

  options.gaming.lutris = lib.mkEnableOption "Lutris";

  config = lib.mkIf config.gaming.lutris {
    environment.systemPackages = with pkgs; [
      lutris
      amdvlk # Vulkan drivers (probably already installed)
      wineWowPackages.stable # 32-bit and 64-bit wineWowPackages
    ];
  };

}
