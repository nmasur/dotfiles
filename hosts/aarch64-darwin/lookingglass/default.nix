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
    # work.enable = true;
    # extra.enable = true;
    # gaming.enable = true;
  };

  # Corporate network runs a TLS-intercepting proxy. Trust its root CA so Nix
  # fetches don't fail with "self-signed certificate in certificate chain". The
  # cert lives outside this public repo at a root-owned, world-readable path so
  # the unprivileged Nix build user can read it (a copy under $HOME is not
  # traversable by nixbld). See docs/CHANGELOG.md to extract and install it.
  nmasur.presets.security.corporateCa = {
    enable = true;
    certFile = "/etc/ssl/corp-ca/CorpCA.pem";
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
      darwin-gaming.enable = true;
      llm-development.enable = true;
      power-user.enable = true;
      work.enable = true;
      experimental.enable = true;
    };
    nmasur.presets.services.mbsync.user = "noah";
    nmasur.presets.programs.git-work.work = {
      name = "Noah-Masur_1701";
      email = "${nmasur.settings.username}@take2games.com";
    };
    home.stateVersion = "23.05";
  };

  system.stateVersion = 5;
}
