This repository contains configuration files for my NixOS, macOS, and WSL
hosts.

They are organized and managed by [Nix](https://nixos.org), so some of the
configuration may be difficult to translate to a non-Nix system.

However, some of the configurations are easier to lift directly:

- [Neovim](https://github.com/nmasur/dotfiles/tree/master/modules/neovim/config)
- [Fish functions](https://github.com/nmasur/dotfiles/tree/master/modules/shell/fish/functions)
- [More fish aliases](https://github.com/nmasur/dotfiles/blob/master/modules/shell/fish/default.nix)
- [Git aliases](https://github.com/nmasur/dotfiles/blob/master/modules/shell/git.nix)
- [Hammerspoon](https://github.com/nmasur/dotfiles/tree/master/modules/darwin/hammerspoon)

Try out my Neovim config:

```bash
nix run github:nmasur/dotfiles#neovim
```

Or build it as a package:

```bash
nix build github:nmasur/dotfiles#neovim
```

If you already have a Neovim configuration, you may need to move it out of
`~/.config/nvim` or set `XDG_CONFIG_HOME` to another value; otherwise, both
configs might conflict with each other.

---

# Installation

## NixOS - From Live Disk

Format drives and build system from any NixOS host, including the live
installer disk:

**This will erase your drives; use at your own risk!**

```bash
lsblk # Choose the disk you want to wipe
nix-shell -p nixVersions.stable
nix run github:nmasur/dotfiles#installer -- nvme0n1 desktop
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
sudo nixos-rebuild switch --flake github:nmasur/dotfiles#wsl
```

You should also download the
[FiraCode](https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/FiraCode.zip)
font and install it on Windows. Install [Alacritty](https://alacritty.org/) and
move the `windows/alacritty.yml` file to
`C:\Users\<user>\AppData\Roaming\alacritty`.

## macOS

To get started on a bare macOS installation, first install Nix:

```bash
sh -c "$(curl -L https://nixos.org/nix/install)"
```

Then use Nix to build nix-darwin:

```bash
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer
```

Then switch to the macOS configuration:

```bash
darwin-rebuild switch --flake github:nmasur/dotfiles#macbook
```

### Dealing with corporate MITM SSL certificates:

```bash
# Get the certificates
openssl s_client -showcerts -verify 5 -connect cache.nixos.org:443 < /dev/null

# Paste them in here
sudo nvim $NIX_SSL_CERT_FILE
```

---

# Flake Templates

You can also use the [templates](./templates/) as flakes for starting new
projects:

```bash
nix flake init --template github:nmasur/dotfiles#poetry
```
