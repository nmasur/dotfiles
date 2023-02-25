# The Staff
# ISO configuration for my USB drive

{ inputs, system, ... }:

with inputs;

nixos-generators.nixosGenerate {
  inherit system;
  format = "install-iso";
  modules = [{
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
    environment.systemPackages =
      with (import inputs.nixpkgs { inherit system; }); [
        git
        vim
        wget
        curl
      ];
  }];
}
