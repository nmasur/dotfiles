{ pkgs, ... }: {

  # Inspired by https://github.com/cleverca22/nix-tests/blob/master/kexec/justdoit.nix
  # This script will partition and format drives; use at your own risk!

  type = "app";

  program = builtins.toString (pkgs.writeShellScript "installer" ''
    #!${pkgs.stdenv.shell}

    set -e

    DISK=$1
    FLAKE=$2
    PARTITION_PREFIX=""

    if [ -z "$DISK" ] || [ -z "$FLAKE" ]; then
        echo "Missing required parameter."
        echo "Usage: installer -- <disk> <host>"
        echo "Example: installer -- nvme0n1 desktop"
        echo "Flake example: nix run github:nmasur/dotfiles#installer -- nvme0n1 desktop"
        echo "(exiting)"
        exit 1
    fi

    case "$DISK" in nvme*)
        PARTITION_PREFIX="p"
    esac

    parted /dev/''${DISK} -- mklabel gpt
    parted /dev/''${DISK} -- mkpart primary 512MiB 100%
    parted /dev/''${DISK} -- mkpart ESP fat32 1MiB 512MiB
    parted /dev/''${DISK} -- set 3 esp on
    mkfs.ext4 -L nixos /dev/''${DISK}''${PARTITION_PREFIX}1
    mkfs.fat -F 32 -n boot /dev/''${DISK}''${PARTITION_PREFIX}2

    mount /dev/disk/by-label/nixos /mnt
    mkdir --parents /mnt/boot
    mount /dev/disk/by-label/boot /mnt/boot

    nixos-install --flake github:nmasur/dotfiles#''${FLAKE}
  '');

}
