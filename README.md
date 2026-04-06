# nixpc — NixOS Configuration

NixOS flake configuration for `nixpc`. Authored on Bazzite, applied via `nixos-rebuild switch` after installing NixOS on the target machine.

## Structure

```
flake.nix                          # Entry point — pins nixpkgs-unstable + home-manager
configuration.nix                  # System root — boot, user, nix settings
hardware-configuration.nix         # REPLACE with nixos-generate-config output at install time
home.nix                           # Home Manager root (user: luke)
modules/
  system/
    hardware.nix                   # AMD GPU, Vulkan, 32-bit graphics, firmware
    desktop.nix                    # KDE Plasma 6 + Hyprland, SDDM, Wayland, Flatpak
    audio.nix                      # PipeWire (ALSA, PulseAudio, JACK compat)
    gaming.nix                     # Steam, Gamescope, GameMode, MangoHud, Lutris, nix-ld
    virtualisation.nix             # libvirtd (virt-manager), Podman
    network.nix                    # NetworkManager, KDE Connect, systemd-resolved
  home/
    shell.nix                      # fish, tmux, starship, atuin, zoxide, direnv
    cli.nix                        # eza, bat, fd, ripgrep, and other CLI tools
    dev.nix                        # neovim, git, gh, glab, shellcheck, node, python, uv, claude-code
    apps.nix                       # GUI apps: Firefox, Bitwarden, Obsidian, GIMP, OBS, etc.
```

## Applying Changes

```bash
# Apply after editing any module
sudo nixos-rebuild switch --flake .#nixpc

# Update all inputs to latest nixpkgs-unstable commit
nix flake update

# Roll back to previous generation if something breaks
sudo nixos-rebuild switch --rollback

# List all system generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

## First-Time Install

1. Download the [NixOS minimal ISO](https://nixos.org/download/) and boot it on the target machine
2. Partition your disks (EFI partition + root partition)
3. Mount partitions at `/mnt` and run:
   ```bash
   nixos-generate-config --root /mnt
   ```
4. Replace `hardware-configuration.nix` in this repo with the generated file at `/mnt/etc/nixos/hardware-configuration.nix`
5. Update `time.timeZone` in `configuration.nix` if needed (currently "America/Chicago")
6. Update `networking.hostName` in `modules/system/network.nix` if needed (currently "nixpc")
7. Update `userEmail` in `modules/home/dev.nix` with your real email
8. Clone this repo to the target and run:
   ```bash
   sudo nixos-rebuild switch --flake .#nixpc
   ```

## After First Boot

| What | How |
|------|-----|
| **Flatpak / Flathub** | Flathub is added automatically on first boot. Open KDE Discover to browse apps. |
| **Proton-GE** | Open ProtonUp-Qt (included) to install custom Proton versions |
| **Login sessions** | SDDM shows both KDE Plasma and Hyprland — KDE is pre-selected |
| **VM management** | Open virt-manager; luke is in the `libvirtd` group (no sudo needed) |
| **Claude Code** | Installed via nixpkgs (`claude-code` package) |

## Key Design Decisions

- **nixos-unstable channel** — Latest Mesa, Steam, and GPU patches for gaming
- **Zen kernel** — Lower-latency gaming patches (`linuxPackages_zen`)
- **Flakes** — Reproducible, pinned dependencies; roll back anytime
- **Home Manager as NixOS module** — User config and system config built together
- **nix-ld enabled** — Allows Proton and Steam runtime binaries to find dynamic libraries
- **Flatpak + Flathub** — Available for apps that update faster than nixpkgs or prefer sandboxing
