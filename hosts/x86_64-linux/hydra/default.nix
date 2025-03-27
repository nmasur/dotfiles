# The Hydra
# System configuration for WSL

rec {
  # Hardware
  networking.hostName = "hydra";

  nmasur.settings = {
    username = "noah";
    fullName = "Noah Masur";
  };

  nmasur.profiles = {
    base.enable = true;
    wsl.enable = true;
  };

  home-manager.users."noah" = {
    nmasur.settings = {
      username = nmasur.settings.username;
      fullName = nmasur.settings.fullName;
    };
    nmasur.profiles = {
      common.enable = true;
      linux-base.enable = true;
      power-user.enable = true;
    };
    home.stateVersion = "23.05";
  };

  system.stateVersion = "23.05";

}
