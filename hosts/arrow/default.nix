# The Arrow
# System configuration for temporary VM

{
  inputs,
  globals,
  overlays,
  ...
}:

inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { };
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
    }
  ];
}
