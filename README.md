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
    backup.nix                     # rclone + Backblaze B2 backup, exclude list, nightly systemd timer
scripts/
  backup_home.sh                   # Backup script (managed by backup.nix, placed at ~/backup_home.sh)
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

## How nixos-rebuild Works

When you run `nixos-rebuild switch --flake ~/projects/nixmigrate#nixpc`, NixOS does **not** copy or deploy your `.nix` files anywhere. Instead:

1. It **reads** all `.nix` files from `~/projects/nixmigrate` in place
2. **Evaluates** the full expression — flake → configuration.nix → all modules — into one config tree
3. **Builds** a new system derivation in `/nix/store` (the immutable package store)
4. **Switches** `/run/current-system` to point at the new build

Your `~/projects/nixmigrate/` folder is the **source code** for your system, not something that gets deployed. Edit a file, run `nixos-rebuild switch`, change is live. If you deleted the folder entirely, your running system would continue working — it's already built in `/nix/store`. This is also why rollback works: previous builds are still in `/nix/store` and the system just switches its pointer back.

## Installation

### Phase 1: From the NixOS Installer

Boot the NixOS ISO. After partitioning and mounting your drives to `/mnt`:

```bash
# Generate hardware config for your actual hardware
nixos-generate-config --root /mnt

# Get git in the live environment
nix-shell -p git

# Clone this repo
cd /tmp
git clone https://github.com/lukecloud-cyber/nixmigrate

# Replace the placeholder hardware config with the real one
cp /mnt/etc/nixos/hardware-configuration.nix /tmp/nixmigrate/hardware-configuration.nix

# Install from the flake
nixos-install --flake /tmp/nixmigrate#nixpc

# Set root password when prompted, then reboot
```

> **Note:** `nixos-install --flake` is used during initial installation from the ISO only. All future changes use `nixos-rebuild switch --flake`.

### Phase 2: After First Boot

You'll land in KDE with the full config applied. Clone the repo to your permanent home location and commit the real hardware config:

```bash
git clone https://github.com/lukecloud-cyber/nixmigrate ~/projects/nixmigrate
cd ~/projects/nixmigrate

# Commit the real hardware-configuration.nix so the repo is complete
cp /etc/nixos/hardware-configuration.nix ./hardware-configuration.nix
git add hardware-configuration.nix
git commit -m "feat: add real hardware-configuration.nix for nixpc"
git push
```

Update any personal details that weren't changed before install:

| File | What to update |
|------|----------------|
| `configuration.nix` | `time.timeZone` (currently `"America/Chicago"`) |
| `modules/system/network.nix` | `networking.hostName` (currently `"nixpc"`) |
| `modules/home/dev.nix` | `userEmail` for git identity |

Apply any changes with:

```bash
sudo nixos-rebuild switch --flake ~/projects/nixmigrate#nixpc
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
