{ config, pkgs, ... }: {

  home-manager.users.${config.user} = {
    programs.gpg.enable = true;
    services.gpg-agent = {
      enable = true;
      defaultCacheTtl = 86400; # Resets when used
      defaultCacheTtlSsh = 86400; # Resets when used
      maxCacheTtl = 34560000; # Can never reset
      maxCacheTtlSsh = 34560000; # Can never reset
      pinentryFlavor = "tty";
    };
    home.packages = with pkgs; [ pinentry ];
  };

}
