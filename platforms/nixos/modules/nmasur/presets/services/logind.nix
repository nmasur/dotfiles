{ config, lib, ... }:

let
  cfg = config.nmasur.presets.services.logind;
in
{

  options.nmasur.presets.services.logind.enable = lib.mkEnableOption "Logind power key management";

  config = lib.mkIf cfg.enable {

    # Use power button to sleep instead of poweroff
    services.logind.settings.Login.HandlePowerKey = "suspend";
    services.logind.settings.Login.HandlePowerKeyLongPress = "poweroff";

  };

}
