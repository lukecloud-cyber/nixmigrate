# nixmigrate — NixOS Configurations

NixOS flake managing two hosts: a bare-metal workstation (`nixpc`) and a QEMU/KVM virtual machine (`nixvm`). A standalone flake (`slyhypr`) provides a riced Hyprland desktop based on [Sly-Harvey/NixOS](https://github.com/Sly-Harvey/NixOS). Authored on Bazzite, applied via `nixos-rebuild switch` after installing NixOS on the target machine.

## Hosts

| Host | Target | Kernel | Extras |
|------|--------|--------|--------|
| `nixpc` | Bare-metal AMD workstation | Zen (low-latency gaming) | GPU drivers, Steam, Gamescope, libvirtd, Podman, rclone backup |
| `nixvm` | QEMU/KVM virtual machine | Default nixpkgs | SPICE agent, QEMU guest agent (no GPU drivers, gaming, or virtualisation) |

Both hosts share the same desktop environment (KDE Plasma 6 + Hyprland via SDDM), shell setup, CLI tools, dev tools, and GUI apps. The VM omits hardware-specific and gaming modules.

### Standalone Flake: slyhypr

| Host | Target | Desktop | Extras |
|------|--------|---------|--------|
| `nixpc` | Bare-metal AMD workstation | [Sly-Harvey Hyprland](https://github.com/Sly-Harvey/NixOS) | Catppuccin theme, waybar stylish, AMD GPU, Steam, Gamescope, KDE Plasma fallback |
| `nixlap` | Laptop | [Sly-Harvey Hyprland](https://github.com/Sly-Harvey/NixOS) | Catppuccin theme, waybar stylish, AMD GPU, Bluetooth, KDE Plasma fallback (no virtualisation or gaming) |
| `nixvm` | QEMU/KVM virtual machine | [Sly-Harvey Hyprland](https://github.com/Sly-Harvey/NixOS) | Catppuccin theme, waybar stylish, 1920x1200 display, KDE Plasma fallback, SPICE agent |

`slyhypr/` is a self-contained flake forked from [Sly-Harvey/NixOS](https://github.com/Sly-Harvey/NixOS) that provides a fully-riced Hyprland desktop with Catppuccin theming, waybar, rofi, hyprlock, and custom scripts. KDE Plasma 6 is enabled alongside Hyprland as a fallback (selectable at SDDM login). Apply with `nixos-rebuild switch --flake ~/projects/nixmigrate/slyhypr#nixvm`, `#nixpc`, or `#nixlap`.

## Structure

```
flake.nix                              # Entry point — pins nixpkgs-unstable + home-manager + mcp-nixos
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
    dev.nix                            # neovim + LazyVim, git, gh, glab, shellcheck, node, python, uv, claude-code, gemini-cli, MCP configs
    apps.nix                           # GUI apps: Firefox, Bitwarden, Obsidian, GIMP, OBS, etc.
    backup.nix                         # rclone + Backblaze B2 backup, nightly systemd timer (nixpc only)
dotfiles/
  nvim/                                # LazyVim starter config (placed at ~/.config/nvim by home-manager)
scripts/
  backup_home.sh                       # Backup script (managed by backup.nix, placed at ~/backup_home.sh)
```

### slyhypr/ — Standalone Sly-Harvey Hyprland Flake

```
slyhypr/
  flake.nix                            # Pins nixpkgs-unstable + home-manager + many inputs (nixvim, spicetify, etc.)
  hosts/
    Default/                           # Template host config
    nixpc/                             # PC host — AMD GPU, gaming, virtualisation, KDE fallback
    nixlap/                            # Laptop host — AMD GPU, Bluetooth, TLP, KDE fallback
    nixvm/                             # VM host — BIOS GRUB, SPICE agents, 1920x1200, KDE fallback
  modules/
    default.nix                        # Hub — aggregates all modules, uses variables.nix for dynamic selection
    core/                              # System fundamentals (22 files)
      bash.nix                         # Bash shell config via Home Manager — starship, direnv, shell options, aliases
      zsh.nix                          # Zsh config — lazy-loaded plugins, fzf-tab, zsh-defer, aliases
      boot.nix                         # Filesystem support, kernel params, GRUB theme, EFI loader
      dns.nix                          # AdGuard Home + Unbound DNS
      fonts.nix                        # System fonts (Nerd Fonts, etc.)
      games.nix                        # Steam, Gamescope, MangoHud, Lutris, Heroic (conditional on vars.games)
      hardware.nix                     # Firmware, Bluetooth, kernel modules
      network.nix                      # NetworkManager, TCP tuning
      nh.nix                           # Nix helper with auto-clean
      packages.nix                     # System packages — CLI tools (bat, delta, dust, duf, fd, ripgrep, etc.)
      sddm.nix                        # SDDM display manager theme
      security.nix                     # Polkit, sudo, security settings
      services.nix                     # PipeWire, Bluetooth, SSH, fstrim, udisks2
      starship.nix                     # Starship prompt with language-specific symbols
      system.nix                       # Nix settings, locale, timezone, state version
      users.nix                        # User account, groups, initial password
      printing.nix, ssh.nix, syncthing.nix, dlna.nix, flatpak.nix, virtualisation.nix
    hardware/
      drives.nix                       # Extra drive mounts (NTFS games, ext4 work)
      video/                           # GPU drivers — selected via ${vars.videoDriver}
        amdgpu.nix, intel.nix, nvidia.nix, nvk.nix
    desktop/                           # Desktop environments — selected via ${vars.desktop}
      hyprland/
        default.nix                    # Hyprland compositor config (keybinds, animations, window rules, monitors)
        scripts/                       # 20 helper scripts (screenshot, screen-record, wallpaper, gamemode, etc.)
        programs/                      # Hyprland companion programs
          dunst.nix                    # Notification daemon
          hypridle.nix                 # Idle management (lock/suspend timers)
          hyprlock.nix                 # Lock screen with wallpaper
          hyprpanel.nix                # AGS-based panel (alternative bar)
          noctalia.nix                 # Noctalia shell (alternative bar)
          swaync.nix                   # SwayNC notification center
          swaylock.nix                 # Swaylock screen locker
          rofi/                        # App launcher (with themes, assets, launcher types)
          waybar/                      # Status bar — stylish.nix, minimal.nix
          wlogout/                     # Logout menu (with icons)
      gnome/                           # GNOME desktop (dconf settings, extensions)
      i3/                              # i3 window manager (polybar, picom, dunst, keybindings)
      plasma6/                         # KDE Plasma 6 (panels, widgets, power management)
    programs/
      browser/                         # Selected via ${vars.browser}
        brave/, firefox/, floorp/, zen-beta/
      terminal/                        # Selected via ${vars.terminal}
        alacritty/, kitty/
      editor/                          # Selected via ${vars.editor}
        neovim/, nixvim/, helix/, vscode/, doom-emacs/, nvchad/
      cli/                             # CLI tools
        default.nix                    # Aggregator
        btop.nix                       # System monitor (Catppuccin theme)
        cava.nix                       # Audio visualizer
        direnv.nix                     # Per-directory environments
        lazygit.nix                    # Git TUI + delta pager config
        tmux.nix                       # Terminal multiplexer (Catppuccin, vim keys)
        yazi.nix                       # File manager TUI
        fastfetch/                     # System info (with custom icons)
        lf/                            # File manager TUI (with icons)
      media/                           # Media applications
        discord.nix                    # Discord + Vencord (Catppuccin, 100+ plugin configs)
        mpv.nix                        # Video player (keybinds, MPRIS, thumbnails)
        obs-studio.nix                 # Screen recording (Wayland plugins)
        spicetify.nix                  # Spotify theming (Catppuccin, adblock)
        thunderbird.nix                # Email client (Catppuccin)
        youtube-music.nix              # YouTube Music desktop (Catppuccin, plugins)
      misc/                            # Miscellaneous system tools
        cpufreq.nix                    # CPU frequency scaling
        lact.nix                       # AMD GPU fan/clock/power control
        thunar.nix                     # File manager (archive, volume plugins)
        tlp.nix                        # Laptop power management
    scripts/                           # System utility scripts
      default.nix                      # Script aggregator (callPackage pattern)
      rebuild.nix, rollback.nix, launcher.nix, network.nix,
      tmux-sessionizer.nix, extract.nix, driverinfo.nix, underwatt.nix
    themes/                            # GTK/Qt themes + wallpapers
      Catppuccin/, Dracula/, rose-pine/
      wallpapers/                      # Wallpaper images
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

Boot the NixOS ISO and run through the graphical installer normally (partition disks, create your user account, etc.). **Use a different username than `luke`** (e.g. `install` or the default) — the flake will create the `luke` account with the correct config in Phase 2. Reboot when finished.

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

### Phase 2b: Set the Password for `luke`

The rebuild creates the `luke` account but `initialPassword` may not take effect reliably. Boot the NixOS ISO again and set the password manually:

1. Boot the NixOS installer ISO
2. Open a terminal and find your disk layout: `lsblk -f`
3. Mount your installed system and set the password:

**Unencrypted drive:**

```bash
sudo mount /dev/vda1 /mnt        # adjust device name for your disk
sudo nixos-enter --root /mnt
passwd luke
exit
sudo umount /mnt
reboot
```

**LUKS-encrypted drive:**

```bash
# Decrypt the LUKS partition (adjust device to match your disk)
sudo cryptsetup luksOpen /dev/nvme0n1p2 cryptroot
sudo mount /dev/mapper/cryptroot /mnt
sudo mount /dev/nvme0n1p1 /mnt/boot    # mount boot partition too
sudo nixos-enter --root /mnt
passwd luke
exit
sudo umount /mnt/boot
sudo umount /mnt
sudo cryptsetup luksClose cryptroot
reboot
```

You can now log in as `luke` with the password you just set.

### Phase 3: Permanent Setup

After rebooting, log in as `luke`. Change your password if needed:

```bash
passwd
```

Then clone the repo to your permanent home location and commit the real hardware config:

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
| `modules/home/dev.nix` | `userEmail` for git identity |

## Applying Changes

```bash
# Apply after editing any module (use the host name that matches your machine)
sudo nixos-rebuild switch --flake ~/projects/nixmigrate#nixpc
sudo nixos-rebuild switch --flake ~/projects/nixmigrate#nixvm

# Apply the Sly-Harvey Hyprland rice instead (pick your host)
sudo nixos-rebuild switch --flake ~/projects/nixmigrate/slyhypr#nixpc
sudo nixos-rebuild switch --flake ~/projects/nixmigrate/slyhypr#nixlap
sudo nixos-rebuild switch --flake ~/projects/nixmigrate/slyhypr#nixvm

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
| **Claude Code** | Installed via nixpkgs (`claude-code` package). Global settings (`~/.claude/settings.json`) managed by Home Manager via `dev.nix`. Project-level MCP servers configured in `.mcp.json` at the repo root. |
| **Gemini CLI** | Installed via nixpkgs (`gemini-cli` package). Global settings (`~/.gemini/settings.json`) managed by Home Manager via `dev.nix`, including MCP server config for `mcp-nixos`. |
| **MCP servers** | [mcp-nixos](https://github.com/utensils/mcp-nixos) is added as a flake input in `flake.nix`. It provides NixOS package, option, and version context to AI tools. Configured globally for Gemini (via Home Manager) and per-project for Claude (via `.mcp.json`). |
| **Neovim / LazyVim** | Config is placed by home-manager. Open `nvim` after first rebuild — plugins download automatically on first launch (needs internet). Customize via `dotfiles/nvim/lua/plugins/`. |

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
- **slyhypr standalone flake** — Alternative desktop config forked from [Sly-Harvey/NixOS](https://github.com/Sly-Harvey/NixOS) for a fully-riced Hyprland experience; self-contained in `slyhypr/` with its own flake inputs, modules, and host configs
- **AI tool configs via Home Manager** — Global settings for Claude Code and Gemini CLI (including MCP server definitions) are declared in `dev.nix`, so they stay in sync across rebuilds and hosts
