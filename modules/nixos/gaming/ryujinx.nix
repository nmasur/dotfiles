{
  config,
  pkgs,
  lib,
  ...
}:
{

  options.gaming.ryujinx.enable = lib.mkEnableOption "Ryujinx Nintendo Switch application.";

  config = lib.mkIf config.gaming.ryujinx.enable {
    environment.systemPackages = with pkgs; [ ryujinx ];

    home-manager.users.${config.user}.xdg.desktopEntries.ryujinx = lib.mkIf pkgs.stdenv.isLinux {
      name = "Ryujinx";
      exec = "env DOTNET_EnableAlternateStackCheck=1 Ryujinx -r /home/${config.user}/media/games/ryujinx/ %f";
    };
  };
}
