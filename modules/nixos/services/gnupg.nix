# GPG is an encryption tool. This isn't really in use for me at the moment.

{
  config,
  pkgs,
  lib,
  ...
}:
{

  options.gpg.enable = lib.mkEnableOption "GnuPG encryption.";

  config.home-manager.users.${config.user} = lib.mkIf config.gpg.enable {
    programs.gpg.enable = true;
    services.gpg-agent = {
      enable = true;
      defaultCacheTtl = 86400; # Resets when used
      defaultCacheTtlSsh = 86400; # Resets when used
      maxCacheTtl = 34560000; # Can never reset
      maxCacheTtlSsh = 34560000; # Can never reset
      pinentryFlavor = "tty";
    };
    home = lib.mkIf config.gui.enable { packages = with pkgs; [ pinentry ]; };
  };
}
