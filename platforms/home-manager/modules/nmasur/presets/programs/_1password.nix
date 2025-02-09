{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs._1password;
in

{

  options.nmasur.presets.programs._1password.enable = lib.mkEnableOption "1Password password manager";

  config = lib.mkIf cfg.enable {
    allowUnfreePackages = [
      "1password"
      "_1password-gui"
      "1password-cli"
      "onepassword-password-manager" # Firefox extension
    ];
    home.packages = [
      pkgs._1password-cli
    ] ++ (if pkgs.stdenv.isLinux then [ pkgs._1password-gui ] else [ ]);

    # Firefox extension
    programs.firefox.profiles.default.extensions =
      pkgs.nur.repos.rycee.firefox-addons.onepassword-password-manager;
  };

  # # https://1password.community/discussion/135462/firefox-extension-does-not-connect-to-linux-app
  # # On Mac, does not apply: https://1password.community/discussion/142794/app-and-browser-integration
  # # However, the button doesn't work either:
  # # https://1password.community/discussion/140735/extending-support-for-trusted-web-browsers
  # environment.etc."1password/custom_allowed_browsers".text = ''
  #   ${
  #     config.home-manager.users.${config.user}.programs.firefox.package
  #   }/Applications/Firefox.app/Contents/MacOS/firefox
  #   firefox
  # '';
}
