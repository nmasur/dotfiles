# The Arrow
# System configuration for temporary VM

{
  inputs,
  globals,
  overlays,
  ...
}:

inputs.nixpkgs.lib.nixosSystem rec {
  system = "x86_64-linux";
  specialArgs = {
    pkgs-caddy = import inputs.nixpkgs-caddy { inherit system; };
  };
  modules = import ./modules.nix { inherit inputs globals overlays; } ++ [
    {
      # This is the root filesystem containing NixOS
      fileSystems."/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };

      # This is the boot filesystem for Grub
      fileSystems."/boot" = {
        device = "/dev/disk/by-label/boot";
        fsType = "vfat";
      };

      virtualisation.vmVariant = {
        virtualisation.forwardPorts = [
          {
            from = "host";
            host.port = 2222;
            guest.port = 22;
          }
        ];
      };
    }
  ];
}
