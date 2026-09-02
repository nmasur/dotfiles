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

    # Ctrl-b: EXECUTE the proven manual cure as a real commandline. The cure
    # is not the variable's end value (it starts and ends at 1) — it is the
    # reader fully exiting readline and re-entering, which only command
    # EXECUTION does. Setting the variable inline (a plain binding body, or the
    # old fish_postexec/fish_cancel hook) never makes the reader exit/re-enter,
    # so it never cured and, with extra repaints on a wedged reader, made it
    # worse. `commandline -f execute` reproduces exactly what typing the cure
    # and pressing Enter does — indistinguishable to fish from the manual cure.
    # Note: this submits the current commandline, so it runs the cure in place
    # of whatever is typed (fine for a rescue key hit at an empty prompt).
    # Ctrl-b chosen because it is otherwise unbound (Ctrl-g is taken).
    nmasur.presets.programs.fish.fish_user_key_bindings = # fish
      ''
        for mode in insert default visual
            bind -M $mode \cb heal-autosuggest
        end
      '';

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
      heal-autosuggest = {
        description = "Heal post-TUI typing lag by executing the autosuggestion-toggle cure (bind to a key)";
        # Replace the commandline with the exact cure the user runs by hand and
        # execute it. Executing (not inline-setting) is what cures: it forces
        # the reader to leave and re-enter readline. Runs in place of whatever
        # is currently typed.
        body = # fish
          ''
            commandline -r 'set -g fish_autosuggestion_enabled 0; and set -g fish_autosuggestion_enabled 1'
            commandline -f execute
          '';
      };
    };

  };
}
