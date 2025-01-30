{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.terraform;
in
{

  options.nmasur.presets.programs.terraform.enable =
    lib.mkEnableOption "Terraform infrastructure management";

  config = lib.mkIf cfg.enable {

    unfreePackages = [ "terraform" ];

    programs.fish.shellAbbrs = {
      te = "terraform";
    };

    home.packages = with pkgs; [
      terraform
      terraform-ls
      tflint
    ];
  };
}
