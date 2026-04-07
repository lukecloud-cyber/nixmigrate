# nixmigrate — NixOS Configurations

NixOS flake managing two hosts: a bare-metal workstation (`nixpc`) and a QEMU/KVM virtual machine (`nixvm`). Authored on Bazzite, applied via `nixos-rebuild switch` after installing NixOS on the target machine.

## Hosts

| Host | Target | Kernel | Extras |
|------|--------|--------|--------|
| `nixpc` | Bare-metal AMD workstation | Zen (low-latency gaming) | GPU drivers, Steam, Gamescope, libvirtd, Podman, rclone backup |
| `nixvm` | QEMU/KVM virtual machine | Default nixpkgs | SPICE agent, QEMU guest agent (no GPU drivers, gaming, or virtualisation) |

Both hosts share the same desktop environment (KDE Plasma 6 + Hyprland via SDDM), shell setup, CLI tools, dev tools, and GUI apps. The VM omits hardware-specific and gaming modules.

## Structure

```
flake.nix                              # Entry point — pins nixpkgs-unstable + home-manager
hosts/
  nixpc/
    configuration.nix                  # System root — Zen kernel, boot, user, nix settings
    hardware-configuration.nix         # REPLACE with nixos-generate-config output at install time
    home.nix                           # Home Manager root (includes backup module)
  nixvm/
    configuration.nix                  # System root — default kernel, SPICE/QEMU guest agents
    hardware-configuration.nix         # REPLACE with nixos-generate-config output at install time
    home.nix                           # Home Manager root (no backup module)
modules/
  system/
    hardware.nix                       # AMD GPU, Vulkan, 32-bit graphics, firmware (nixpc only)
    desktop.nix                        # KDE Plasma 6 + Hyprland, SDDM, Wayland, Flatpak, XDG portals
    audio.nix                          # PipeWire (ALSA, PulseAudio, JACK compat)
    gaming.nix                         # Steam, Gamescope, GameMode, MangoHud, Lutris, nix-ld (nixpc only)
    virtualisation.nix                 # libvirtd (virt-manager), Podman (nixpc only)
    network.nix                        # NetworkManager, KDE Connect, systemd-resolved
  home/
    shell.nix                          # fish, tmux, starship, atuin, zoxide, direnv
    cli.nix                            # eza, bat, fd, ripgrep, fastfetch, and other CLI tools
    dev.nix                            # neovim, git, gh, glab, shellcheck, node, python, uv, claude-code, gemini-cli
    apps.nix                           # GUI apps: Firefox, Bitwarden, Obsidian, GIMP, OBS, etc.
    backup.nix                         # rclone + Backblaze B2 backup, nightly systemd timer (nixpc only)
scripts/
  backup_home.sh                       # Backup script (managed by backup.nix, placed at ~/backup_home.sh)
```

### What each host includes

| Module | nixpc | nixvm |
|--------|:-----:|:-----:|
| `system/hardware.nix` | yes | — |
| `system/desktop.nix` | yes | yes |
| `system/audio.nix` | yes | yes |
| `system/gaming.nix` | yes | — |
| `system/virtualisation.nix` | yes | — |
| `system/network.nix` | yes | yes |
| `home/shell.nix` | yes | yes |
| `home/cli.nix` | yes | yes |
| `home/dev.nix` | yes | yes |
| `home/apps.nix` | yes | yes |
| `home/backup.nix` | yes | — |

## Installation

### Phase 1: Install NixOS with the Graphical Installer

Boot the NixOS ISO and run through the graphical installer normally (partition disks, create your user account, etc.). Reboot when finished.

### Phase 2: Apply Your Flake Config

After rebooting, log in with the account you created during install. Open a terminal and get a shell with git:

```bash
nix-shell -p git
```

Clone this repo and copy the installer-generated hardware config into it:

```bash
cd /tmp
git clone https://github.com/lukecloud-cyber/nixmigrate
```

**For bare-metal (nixpc):**

```bash
cp /etc/nixos/hardware-configuration.nix /tmp/nixmigrate/hosts/nixpc/hardware-configuration.nix
sudo nixos-rebuild switch --flake /tmp/nixmigrate#nixpc
```

**For a VM (nixvm):**

```bash
cp /etc/nixos/hardware-configuration.nix /tmp/nixmigrate/hosts/nixvm/hardware-configuration.nix
sudo nixos-rebuild switch --flake /tmp/nixmigrate#nixvm
```

Reboot to pick up all changes (new user, bootloader, services, etc.).

### Phase 3: Permanent Setup

After rebooting, log in as `luke` (password: `changeme` — change it with `passwd`). Clone the repo to your permanent home location and commit the real hardware config:

**For nixpc:**

```bash
git clone https://github.com/lukecloud-cyber/nixmigrate ~/projects/nixmigrate
cd ~/projects/nixmigrate

cp /etc/nixos/hardware-configuration.nix ./hosts/nixpc/hardware-configuration.nix
git add hosts/nixpc/hardware-configuration.nix
git commit -m "feat: add real hardware-configuration.nix for nixpc"
git push
```

**For nixvm:**

```bash
git clone https://github.com/lukecloud-cyber/nixmigrate ~/projects/nixmigrate
cd ~/projects/nixmigrate

cp /etc/nixos/hardware-configuration.nix ./hosts/nixvm/hardware-configuration.nix
git add hosts/nixvm/hardware-configuration.nix
git commit -m "feat: add real hardware-configuration.nix for nixvm"
git push
```

Update any personal details that weren't changed before install:

| File | What to update |
|------|----------------|
| `hosts/*/configuration.nix` | `time.timeZone` (currently `"America/Chicago"`) |
| `modules/system/network.nix` | `networking.hostName` (currently `"nixpc"`) |
| `modules/home/dev.nix` | `userEmail` for git identity |

## Applying Changes

```bash
# Apply after editing any module (use the host name that matches your machine)
sudo nixos-rebuild switch --flake ~/projects/nixmigrate#nixpc
sudo nixos-rebuild switch --flake ~/projects/nixmigrate#nixvm

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

## After First Boot

| What | How |
|------|-----|
| **Flatpak / Flathub** | Flathub is added automatically on first boot. Open KDE Discover to browse apps. |
| **Proton-GE** (nixpc only) | Open ProtonUp-Qt (included) to install custom Proton versions |
| **Login sessions** | SDDM shows both KDE Plasma and Hyprland — KDE is pre-selected |
| **VM management** (nixpc only) | Open virt-manager; luke is in the `libvirtd` group (no sudo needed) |
| **Claude Code** | Installed via nixpkgs (`claude-code` package) |

### Backups — rclone + Backblaze B2 (nixpc only)

The backup script and nightly timer are installed by the config, but the rclone credentials must be restored manually from Bitwarden — they are intentionally not in this repo.

**Step 1: Restore rclone config from Bitwarden**

```bash
mkdir -p ~/.config/rclone
# Copy the saved rclone.conf from Bitwarden to:
# ~/.config/rclone/rclone.conf
```

**Step 2: Verify the connection**

```bash
rclone lsf vault: --max-depth 1
```

**Step 3: Enable the nightly timer**

```bash
systemctl --user enable --now rclone-backup.timer
```

**Step 4: Confirm everything works**

```bash
~/backup_home.sh --dry-run
```

The timer runs nightly at midnight. If the machine is off at midnight, it will catch up and run on next boot (`Persistent = true`).

## Key Design Decisions

- **nixos-unstable channel** — Latest Mesa, Steam, and GPU patches for gaming
- **Zen kernel** (nixpc only) — Lower-latency gaming patches (`linuxPackages_zen`)
- **Flakes** — Reproducible, pinned dependencies; roll back anytime
- **Home Manager as NixOS module** — User config and system config built together
- **nix-ld enabled** (nixpc only) — Allows Proton and Steam runtime binaries to find dynamic libraries
- **Flatpak + Flathub** — Available for apps that update faster than nixpkgs or prefer sandboxing
- **Dual desktop** — KDE Plasma 6 as the daily driver, Hyprland available as an alternative session
- **UWSM for Hyprland** — Proper systemd session integration via `graphical-session.target`
- **Shared modules** — Both hosts pull from the same `modules/` tree; host-specific differences live in `hosts/*/configuration.nix`
