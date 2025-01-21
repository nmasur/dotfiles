{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.services.gnupg;
in

{

  options.nmasur.presets.services.gnupg.enable = lib.mkEnableOption "GPG encryption tools";

  config = lib.mkIf cfg.enable {
    programs.gpg.enable = true;
    services.gpg-agent = {
      enable = true;
      defaultCacheTtl = 86400; # Resets when used
      defaultCacheTtlSsh = 86400; # Resets when used
      maxCacheTtl = 34560000; # Can never reset
      maxCacheTtlSsh = 34560000; # Can never reset
      pinentryFlavor = "tty";
    };
    home = lib.mkIf config.nmasur.profiles.linux-gui.enable { packages = with pkgs; [ pinentry ]; };
  };
}
