{ config, pkgs, ... }: {

  home-manager.users.${config.user}.home.packages = with pkgs; [
    terraform # Terraform executable
    terraform-ls # Language server
    tflint # Linter
  ];

}
