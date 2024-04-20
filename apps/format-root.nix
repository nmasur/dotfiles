{ pkgs, ... }:
{

  # This script will partition and format drives; use at your own risk!

  type = "app";

  program = builtins.toString (
    pkgs.writeShellScript "format-root" ''
      set -e

      DISK=$1

      if [ -z "''${DISK}" ]; then
          ${pkgs.gum}/bin/gum style --width 50 --margin "1 2" --padding "2 4" \
              --foreground "#fb4934" \
              "Missing required parameter." \
              "Usage: format-root -- <disk>" \
              "Flake example: nix run github:nmasur/dotfiles#format-root -- nvme0n1"
          echo "(exiting)"
          exit 1
      fi

      ${pkgs.disko-packaged}/bin/disko \
          --mode create \
          --dry-run \
          --flake "path:$(pwd)#root" \
          --arg disk \""/dev/''${DISK}"\"

      ${pkgs.gum}/bin/gum confirm \
          "This will ERASE ALL DATA on the disk /dev/''${DISK}. Are you sure you want to continue?" \
          --default=false

      ${pkgs.disko-packaged}/bin/disko \
          --mode create \
          --flake "path:$(pwd)#root" \
          --arg disk "/dev/''${DISK}"

    ''
  );
}
