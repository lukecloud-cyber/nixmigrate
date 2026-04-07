# GEMINI.md

## Project Overview
`nixmigrate` is a NixOS configuration repository using **Nix Flakes** and **Home Manager**. It manages two primary hosts:
- **`nixpc`**: A bare-metal workstation tuned for gaming (Zen kernel, AMD GPU) and virtualization.
- **`nixvm`**: A lightweight QEMU/KVM virtual machine configuration.

The project follows a modular design, separating system-level configuration from user-level Home Manager settings. It targets the `nixos-unstable` channel to provide the latest software and drivers.

## Key Technologies
- **NixOS & Flakes**: For reproducible system builds.
- **Home Manager**: For managing user environments, dotfiles, and CLI tools.
- **Desktop Environments**: KDE Plasma 6 (default) and Hyprland (via SDDM/UWSM).
- **Development Stack**: Neovim (LazyVim), Fish shell, Starship, Atuin, Git, Node.js, Python (uv), and AI tools (`gemini-cli`, `claude-code`).
- **Gaming (nixpc)**: Steam, Gamescope, MangoHud, Lutris.

## Architecture & Directory Structure
- `flake.nix`: The entry point, pinning dependencies and defining host outputs.
- `hosts/`: Host-specific entry points (`configuration.nix`, `home.nix`).
- `modules/system/`: Reusable system-level modules (audio, desktop, gaming, networking, etc.).
- `modules/home/`: Reusable user-level modules (CLI tools, dev environment, apps, shell, etc.).
- `dotfiles/`: Raw configuration files (e.g., Neovim) symlinked or copied by Home Manager.
- `scripts/`: Utility scripts like `backup_home.sh`.

## Essential Commands

### System Management
- **Apply Changes**: `sudo nixos-rebuild switch --flake .#<host>` (e.g., `sudo nixos-rebuild switch --flake .#nixpc`)
- **Update Dependencies**: `nix flake update`
- **Rollback**: `sudo nixos-rebuild switch --rollback`
- **Garbage Collection**: `sudo nix-collect-garbage -d` (or wait for the weekly automatic GC)

### Development
- **Edit Neovim Config**: Files are located in `dotfiles/nvim/`. Changes are applied on the next `nixos-rebuild switch`.
- **Add Packages**: 
  - System-wide: Add to `modules/system/` or `hosts/*/configuration.nix`.
  - User-level: Add to `modules/home/` or `hosts/*/home.nix`.

## Development Conventions
1. **Modularity**: Prefer adding logic to a module in `modules/` and importing it rather than bloating the host configuration.
2. **Host Separation**: Keep hardware-specific or host-specific logic (like the Zen kernel for `nixpc` or guest agents for `nixvm`) within the respective `hosts/` directory.
3. **Home Manager as a Module**: Home Manager is integrated directly into the NixOS configuration. Run `nixos-rebuild` to apply both system and home changes.
4. **Dotfiles Management**: Use `xdg.configFile` in Home Manager to link files from the `dotfiles/` directory to `~/.config/`.
5. **Unfree Packages**: Explicitly enabled via `nixpkgs.config.allowUnfree = true`.

## Future Tasks / TODOs
- [ ] Configure `userEmail` in `modules/home/dev.nix`.
- [ ] Verify `time.timeZone` in `hosts/*/configuration.nix`.
- [ ] Set up `rclone.conf` for backups on `nixpc`.
