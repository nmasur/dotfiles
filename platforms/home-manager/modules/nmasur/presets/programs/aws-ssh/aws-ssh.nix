{ config, lib, ... }:

let
  cfg = config.nmasur.presets.programs.aws-ssh;
in

{
  options.nmasur.presets.programs.aws-ssh.enable = lib.mkEnableOption "AWS SSH tools";

  config = lib.mkIf cfg.enable {

    # Ignore wine directories in searches
    home.file.".ssh/aws-ssm-ssh-proxy-command.sh" = {
      text = builtins.readFile ./aws-ssm-ssh-proxy-command.sh;
      executable = true;
    };

  };
}
