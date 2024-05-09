{
  inputs,
  globals,
  overlays,
}:

[
  globals
  inputs.home-manager.nixosModules.home-manager
  {
    nixpkgs.overlays = overlays;
    networking.hostName = "arrow";
    physical = false;
    server = true;
    gui.enable = false;
    theme.colors = (import ../../colorscheme/gruvbox).dark;
    publicKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB+AbmjGEwITk5CK9y7+Rg27Fokgj9QEjgc9wST6MA3s personal"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKpPU2G9rSF8Q6waH62IJexDCQ6lY+8ZyVufGE3xMDGw deploy"
    ];
    identityFile = "/home/${globals.user}/.ssh/id_ed25519";
    cloudflare.enable = true;
    services.openssh.enable = true;
    services.caddy.enable = true;
    services.n8n.enable = true;

    # nix-index seems to eat up too much memory for Vultr
    home-manager.users.${globals.user}.programs.nix-index.enable = inputs.nixpkgs.lib.mkForce false;
  }
  ../../modules/common
  ../../modules/nixos
]
