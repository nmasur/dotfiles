{ pkgs, ... }:
{

  # Inspired by https://github.com/cleverca22/nix-tests/blob/master/kexec/justdoit.nix
  # This script will partition and format drives; use at your own risk!

  type = "app";

  program = builtins.toString (
    pkgs.writeShellScript "installer" ''
      set -e

      DISK=$1
      FLAKE=$2
      PARTITION_PREFIX=""

      if [ -z "$DISK" ] || [ -z "$FLAKE" ]; then
          ${pkgs.gum}/bin/gum style --width 50 --margin "1 2" --padding "2 4" \
              --foreground "#fb4934" \
              "Missing required parameter." \
              "Usage: installer -- <disk> <host>" \
              "Example: installer -- nvme0n1 tempest" \
              "Flake example: nix run github:nmasur/dotfiles#installer -- nvme0n1 tempest"
          echo "(exiting)"
          exit 1
      fi

      case "$DISK" in nvme*)
          PARTITION_PREFIX="p"
      esac

      ${pkgs.gum}/bin/gum confirm \
          "This will ERASE ALL DATA on the disk /dev/''${DISK}. Are you sure you want to continue?" \
          --default=false

      ${pkgs.parted}/bin/parted /dev/''${DISK} -- mklabel gpt
      ${pkgs.parted}/bin/parted /dev/''${DISK} -- mkpart primary 512MiB 100%
      ${pkgs.parted}/bin/parted /dev/''${DISK} -- mkpart ESP fat32 1MiB 512MiB
      ${pkgs.parted}/bin/parted /dev/''${DISK} -- set 3 esp on
      mkfs.ext4 -L nixos /dev/''${DISK}''${PARTITION_PREFIX}1
      mkfs.fat -F 32 -n boot /dev/''${DISK}''${PARTITION_PREFIX}2

      mount /dev/disk/by-label/nixos /mnt
      mkdir --parents /mnt/boot
      mount /dev/disk/by-label/boot /mnt/boot

      ${pkgs.nixos-install-tools}/bin/nixos-install --flake github:nmasur/dotfiles#''${FLAKE}
    ''
  );
}
