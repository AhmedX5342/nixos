# NixOS Configuration

My personal NixOS configuration built with **flakes** and **Home Manager**.

## Features

- Nix Flakes
- Home Manager
- i3 Window Manager
- Catppuccin Mocha GTK theme
- Rofi application launcher and custom applets
- Polybar
- Picom compositor
- Thunar
- Feh wallpaper management
- CopyQ clipboard manager
- Betterlockscreen
- Flameshot
- PipeWire audio
- Git configuration

## Repository Structure

```
.
├── flake.nix
├── configuration.nix
├── home.nix
├── hardware-configuration.nix
└── dotfiles
    ├── i3
    ├── polybar
    ├── rofi
    ├── picom
    ├── scripts
    └── wallpapers
```

## Installation

Clone the repository:

```bash
git clone https://github.com/AhmedX5342/nixos.git /etc/nixos
cd /etc/nixos
```

Rebuild the system:

```bash
sudo nixos-rebuild switch --flake /etc/nixos
```

## Dotfiles

The desktop configuration is managed through Home Manager.

Configurations include:

- i3
- Polybar
- Rofi
- Picom
- GTK
- Scripts
- Wallpapers
