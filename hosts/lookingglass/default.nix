# The Looking Glass
# System configuration for my work Macbook

{
  inputs,
  globals,
  overlays,
  ...
}:

inputs.darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  specialArgs = { };
  modules = [
    ../../modules/common
    ../../modules/darwin
    (
      globals
      // rec {
        user = "Noah.Masur";
        gitName = "Noah-Masur_1701";
        gitEmail = "${user}@take2games.com";
      }
    )
    inputs.home-manager.darwinModules.home-manager
    inputs.mac-app-util.darwinModules.default
    {
      nixpkgs.overlays = [ inputs.firefox-darwin.overlay ] ++ overlays;
      networking.hostName = "lookingglass";
      networking.computerName = "NYCM-NMASUR1";
      identityFile = "/Users/Noah.Masur/.ssh/id_ed25519";
      gui.enable = true;
      theme = {
        colors = (import ../../colorscheme/gruvbox-dark).dark;
        dark = true;
      };
      mail.user = globals.user;
      atuin.enable = true;
      charm.enable = true;
      neovim.enable = true;
      mail.enable = true;
      mail.aerc.enable = true;
      mail.himalaya.enable = false;
      kitty.enable = true;
      discord.enable = true;
      firefox.enable = true;
      dotfiles.enable = true;
      terraform.enable = true;
      python.enable = true;
      rust.enable = true;
      lua.enable = true;
      obsidian.enable = true;
      kubernetes.enable = true;
      _1password.enable = true;
      slack.enable = true;
      wezterm.enable = true;
      yt-dlp.enable = true;
    }
  ];
}
