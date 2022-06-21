{ config, pkgs, ... }: {

  home-manager.users.${config.user} = {
    programs.fish.shellAbbrs = {
      # Terraform
      te = "terraform";
    };
    home.packages = with pkgs; [
      terraform # Terraform executable
      terraform-ls # Language server
      tflint # Linter
    ];

  };

}
