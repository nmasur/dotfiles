[Back to README](../README.md)

---

# Installation

## NixOS - From Live Disk

Format drives and build system from any NixOS host, including the live
installer disk:

**This will erase your drives; use at your own risk!**

```bash
lsblk # Choose the disk you want to wipe
nix-shell -p nixVersions.stable
nix run github:nmasur/dotfiles#installer -- nvme0n1 tempest
```

## NixOS - From Existing System

If you're already running NixOS, you can switch to this configuration with the
following command:

```bash
nix-shell -p nixVersions.stable
sudo nixos-rebuild switch --flake github:nmasur/dotfiles#tempest
```

## Windows - From NixOS WSL

After [installing NixOS on
WSL](https://xeiaso.net/blog/nix-flakes-4-wsl-2022-05-01), you can switch to
the WSL configuration:

```
nix-shell -p nixVersions.stable
sudo nixos-rebuild switch --flake github:nmasur/dotfiles#hydra
```

You should also download the
[FiraCode](https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/FiraCode.zip)
font and install it on Windows. Install [Alacritty](https://alacritty.org/) and
move the `windows/alacritty.yml` file to
`C:\Users\<user>\AppData\Roaming\alacritty`.

## macOS

To get started on a bare macOS installation, first install Nix:

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Launch a new shell. Then use Nix to switch to the macOS configuration:

```bash
sudo rm /etc/bashrc
sudo rm /etc/nix/nix.conf
export NIX_SSL_CERT_FILE="$HOME/Documents/t2-ca-bundle.pem"
nix \
    --extra-experimental-features flakes \
    --extra-experimental-features nix-command \
    run nix-darwin -- switch \
    --flake github:nmasur/dotfiles#lookingglass
```

Once installed, you can continue to update the macOS configuration:

```bash
darwin-rebuild switch --flake ~/dev/personal/dotfiles
```

