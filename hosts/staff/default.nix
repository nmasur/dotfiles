# The Staff
# ISO configuration for my USB drive

{ self, system, ... }:

self.inputs.nixos-generators.nixosGenerate {
  inherit system;
  format = "install-iso";
  modules = [
    self.nixosModules.global
    self.nixosModules.common
    self.nixosModules.nixos
    ({ config, pkgs, ... }: {
      networking.hostName = "staff";
      users.extraUsers.root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB+AbmjGEwITk5CK9y7+Rg27Fokgj9QEjgc9wST6MA3s"
      ];
      services.openssh = {
        enable = true;
        ports = [ 22 ];
        allowSFTP = true;
        settings = {
          GatewayPorts = "no";
          X11Forwarding = false;
          PasswordAuthentication = false;
          PermitRootLogin = "yes";
        };
      };
      environment.systemPackages = with pkgs; [
        git
        vim
        wget
        curl
        (import ../../modules/common/neovim/package {
          inherit pkgs;
          colors = (import ../../colorscheme/gruvbox).dark;
        })
      ];
      nix.extraOptions = ''
        experimental-features = nix-command flakes
        warn-dirty = false
      '';
    })
  ];
}
