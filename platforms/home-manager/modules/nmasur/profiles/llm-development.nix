{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.nmasur.profiles.llm-development;
in

{

  options.nmasur.profiles.llm-development.enable = lib.mkEnableOption "LLM coding tools";

  config = lib.mkIf cfg.enable {

    home.packages = [

      pkgs.pi-coding-agent # AI LLM Agent

    ];

  };

}
