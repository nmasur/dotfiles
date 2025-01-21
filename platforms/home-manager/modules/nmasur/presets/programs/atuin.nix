{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.atuin;
in

{

  options.nmasur.presets.programs.atuin.enable = lib.mkEnableOption "Atuin shell history sync";

  config = lib.mkIf cfg.enable {
    programs.atuin = {
      enable = true;
      flags = [
        "--disable-up-arrow"
        "--disable-ctrl-r"
      ];
      settings = {
        auto_sync = true;
        update_check = false;
        sync_address = "https://api.atuin.sh";
        search_mode = "fuzzy";
        filter_mode = "host"; # global, host, session, directory
        search_mode_shell_up_key_binding = "fuzzy";
        filter_mode_shell_up_key_binding = "session";
        style = "compact"; # or auto,full
        show_help = true;
        history_filter = [ ];
        secrets_filter = true;
        enter_accept = false;
        keymap_mode = "vim-normal";
      };
    };

  };
}
