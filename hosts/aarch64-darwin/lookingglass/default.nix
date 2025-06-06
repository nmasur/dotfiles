# The Looking Glass
# System configuration for my work Macbook

rec {
  networking.hostName = "NYCM-NMASUR2";
  networking.computerName = "NYCM-NMASUR2";

  nmasur.settings = {
    username = "Noah.Masur";
    fullName = "Noah Masur";
  };

  nmasur.profiles = {
    base.enable = true;
    work.enable = true;
    extra.enable = true;
    gaming.enable = true;
  };

  home-manager.users."Noah.Masur" = {
    nmasur.settings = {
      username = nmasur.settings.username;
      fullName = nmasur.settings.fullName;
      host = "lookingglass";
    };
    nmasur.profiles = {
      common.enable = true;
      darwin-base.enable = true;
      power-user.enable = true;
      work.enable = true;
      experimental.enable = true;
    };
    nmasur.presets.programs.git-work.work = {
      name = "Noah-Masur_1701";
      email = "${nmasur.settings.username}@take2games.com";
    };
    home.stateVersion = "23.05";
  };

  system.stateVersion = 5;
}
