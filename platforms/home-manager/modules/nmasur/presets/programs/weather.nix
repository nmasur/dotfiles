{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.weather;
in

{

  options.nmasur.presets.programs.weather.enable = lib.mkEnableOption "Weather CLI tools";

  config = lib.mkIf cfg.enable {
    # Used in abbreviations and aliases
    home.packages = [ pkgs.curl ];
    programs.fish.shellAbbrs = {

      weather = "curl wttr.in/$WEATHER_CITY";
      moon = "curl wttr.in/Moon";

    };
  };
}
