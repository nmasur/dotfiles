# System Configurations

This repository contains configuration files for my NixOS, macOS, and WSL
hosts.

They are organized and managed by [Nix](https://nixos.org), so some of the
configuration may be difficult to translate to a non-Nix system.

## System Features

| Feature        | Program                                             | Configuration                                                                     |
|----------------|-----------------------------------------------------|-----------------------------------------------------------------------------------|
| OS             | [NixOS](https://nixos.org)                          | [Link](./platforms/nixos)                                                         |
| Display Server | [X11](https://www.x.org/wiki/)                      | [Link](./platforms/nixos/modules/nmasur/profiles/gui.nix)                         |
| Compositor     | [Picom](https://github.com/yshui/picom)             | [Link](./platforms/home-manager/modules/nmasur/presets/services/picom.nix)        |
| Window Manager | [i3](https://i3wm.org/)                             | [Link](./platforms/home-manager/modules/nmasur/presets/services/i3.nix)           |
| Panel          | [Polybar](https://polybar.github.io/)               | [Link](./platforms/home-manager/modules/nmasur/presets/services/polybar.nix)      |
| Font           | [Victor Mono](https://rubjo.github.io/victor-mono/) | [Link](./platforms/home-manager/modules/nmasur/presets/fonts.nix)                 |
| Launcher       | [Rofi](https://github.com/davatorium/rofi)          | [Link](./platforms/home-manager/modules/nmasur/presets/programs/rofi/default.nix) |

## User Features

| Feature      | Program                                                                          | Configuration                                                                 |
|--------------|----------------------------------------------------------------------------------|-------------------------------------------------------------------------------|
| Dotfiles     | [Home-Manager](https://github.com/nix-community/home-manager)                    | [Link](./platforms/home-manager)                                              |
| Terminal     | [Ghostty](https://sw.kovidgoyal.net/kitty/)                                      | [Link](./platforms/home-manager/modules/nmasur/presets/programs/ghostty.nix)  |
| Shell        | [Fish](https://fishshell.com/)                                                   | [Link](./platforms/home-manager/modules/nmasur/presets/programs/fish.nix)     |
| Shell Prompt | [Starship](https://starship.rs/)                                                 | [Link](./platforms/home-manager/modules/nmasur/presets/programs/starship.nix) |
| Colorscheme  | [Gruvbox](https://github.com/morhetz/gruvbox)                                    | [Link](./colorscheme/gruvbox/default.nix)                                     |
| Wallpaper    | [Road](https://gitlab.com/exorcist365/wallpapers/-/blob/master/gruvbox/road.jpg) | [Link](./hosts/x86_64-linux/tempest/default.nix)                              |
| Text Editor  | [Neovim](https://neovim.io/)                                                     | [Link](./pkgs/applications/editors/neovim/nmasur/neovim/package.nix)          |
| Browser      | [Firefox](https://www.mozilla.org/en-US/firefox/new/)                            | [Link](./platforms/home-manager/modules/nmasur/presets/programs/firefox.nix)  |
| E-Mail       | [Aerc](https://aerc-mail.org/)                                                   | [Link](./platforms/home-manager/modules/nmasur/presets/programs/aerc.nix)     |
| File Manager | [Nautilus](https://wiki.gnome.org/action/show/Apps/Files)                        | [Link](./platforms/home-manager/modules/nmasur/presets/programs/nautilus.nix) |
| PDF Reader   | [Zathura](https://pwmt.org/projects/zathura/)                                    | [Link](./platforms/home-manager/modules/nmasur/presets/programs/zathura.nix)  |
| Video Player | [mpv](https://mpv.io/)                                                           | [Link](./platforms/home-manager/modules/nmasur/presets/programs/mpv.nix)      |

## macOS Features

| Feature  | Program                                     | Configuration                        |
|----------|---------------------------------------------|--------------------------------------|
| Keybinds | [Hammerspoon](https://www.hammerspoon.org/) | [Link](./platforms/home-manager/modules/nmasur/presets/services/hammerspoon/) |

# Diagram

![Diagram](https://github.com/nmasur/dotfiles/assets/7386960/4cc22285-cea1-4831-b387-a82241184381)

---

# Unique Configurations

This repo contains a few more elaborate elements of configuration.

- [Neovim config](./pkgs/applications/editors/neovim/nmasur/neovim/package.nix)
generated with Nix2Vim and source-controlled plugins,
differing based on installed LSPs, for example. - [Caddy
JSON](./platforms/nixos/modules/nmasur/presets/services/caddy.nix) file (routes,
etc.) based dynamically on enabled services rendered with Nix. - [Grafana
config](./platforms/nixos/modules/nmasur/presets/services/grafana/grafana.nix)
rendered with Nix. - Custom [secrets
deployment](./platforms/nixos/modules/secrets.nix) similar to agenix. - Base16
[colorschemes](./colorscheme/) applied to multiple applications, including
Firefox userChrome.

---

# Installation

Click [here](./docs/installation.md) for detailed installation instructions.

# Neovim

Try out my Neovim config with nix:

```bash
nix run github:nmasur/dotfiles#neovim
```

Or build it as a package:

```bash
nix build github:nmasur/dotfiles#neovim
```

If you already have a Neovim configuration, you may need to move it out of
`~/.config/nvim` or set `XDG_CONFIG_HOME` to another value; otherwise both
configs might conflict with each other.

# Flake Templates

You can also use the [templates](./templates/) as flakes for starting new
projects:

```bash
nix flake init --template github:nmasur/dotfiles#poetry
```
