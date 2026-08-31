{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.lag-triage;

  term-probe = pkgs.writeScriptBin "term-probe" ''
    #!${lib.getExe pkgs.python3}
    ${builtins.readFile ./term_probe.py}
  '';
in

{

  options.nmasur.presets.programs.lag-triage.enable =
    lib.mkEnableOption "Terminal input-lag triage tools";

  config = lib.mkIf cfg.enable {

    home.packages = [ term-probe ];

    programs.fish.functions = {
      lag-triage = {
        description = "Diagnose post-TUI typing lag in the current shell";
        body = builtins.readFile ./lag-triage.fish;
      };
      unlag = {
        description = "Reset terminal state left behind by a TUI";
        body = builtins.readFile ./unlag.fish;
      };
      lag-sample = {
        description = "Stack-sample fish and zellij while typing lag is happening";
        body = builtins.readFile ./lag-sample.fish;
      };
      __autosuggestion_unwedge = {
        description = "Reset autosuggestion state after each command to prevent post-TUI typing lag";
        onEvent = "fish_postexec";
        body = builtins.readFile ./autosuggestion-unwedge.fish;
      };
    };

  };
}
