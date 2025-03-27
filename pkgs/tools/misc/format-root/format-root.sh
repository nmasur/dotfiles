#!/usr/bin/env bash

set -e

DISK=$1

if [ -z "${DISK}" ]; then
    gum style --width 50 --margin "1 2" --padding "2 4" \
        --foreground "#fb4934" \
        "Missing required parameter." \
        "Usage: format-root -- <disk>" \
        "Flake example: nix run github:nmasur/dotfiles#format-root -- nvme0n1"
    echo "(exiting)"
    exit 1
fi

disko \
    --mode create \
    --dry-run \
    --flake "path:$(pwd)#root" \
    --arg disk \""/dev/${DISK}"\"

gum confirm \
    "This will ERASE ALL DATA on the disk /dev/${DISK}. Are you sure you want to continue?" \
    --default=false

disko \
    --mode create \
    --flake "path:$(pwd)#root" \
    --arg disk "/dev/${DISK}"
