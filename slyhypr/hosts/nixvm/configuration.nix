{ lib, pkgs, ... }:
let
  vars = import ./variables.nix;
in
{
  imports = [
    ./hardware-configuration.nix
    ./host-packages.nix

    # Core Modules
    ../../modules/scripts
    ../../modules/core/boot.nix
    ../../modules/core/bash.nix
    ../../modules/core/zsh.nix
    ../../modules/core/starship.nix
    ../../modules/core/fonts.nix
    ../../modules/core/hardware.nix
    ../../modules/core/network.nix
    ../../modules/core/dns.nix
    ../../modules/core/nh.nix
    ../../modules/core/packages.nix
    ../../modules/core/printing.nix
    ../../modules/core/sddm.nix
    ../../modules/core/security.nix
    ../../modules/core/services.nix
    ../../modules/core/system.nix
    ../../modules/core/users.nix

    # Desktop & programs (no GPU driver module — VM uses virtio/QXL)
    ../../modules/desktop/${vars.desktop}
    ../../modules/programs/browser/${vars.browser}
    ../../modules/programs/terminal/${vars.terminal}
    ../../modules/programs/editor/${vars.editor}
    ../../modules/programs/cli/${vars.tuiFileManager}
    ../../modules/programs/cli/tmux
    ../../modules/programs/cli/direnv
    ../../modules/programs/cli/lazygit
    ../../modules/programs/cli/btop
    ../../modules/programs/media/mpv
    ../../modules/programs/misc/thunar

    # VM-only: skip drives, gaming, lact, syncthing, cava, spicetify, discord, tlp
  ];

  # ── VM boot: BIOS GRUB (override the EFI defaults from boot.nix) ────
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.loader.grub.device = lib.mkForce "/dev/vda";
  boot.loader.grub.efiSupport = lib.mkForce false;
  boot.loader.grub.useOSProber = lib.mkForce false;

  # ── QEMU/SPICE guest agents ─────────────────────────────────────────
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  # ── KDE Plasma 6 alongside Hyprland (selectable at SDDM) ───────────
  services.desktopManager.plasma6.enable = true;

  # ── Fish shell (in addition to zsh from variables) ──────────────────
  programs.fish.enable = true;

  # ── Home Manager overrides ────────────────────────────────────────────
  home-manager.sharedModules = [
    (_: {
      home.stateVersion = lib.mkForce "24.11";
      # Hyprland monitor: 1920x1200 for VM virtual display
      wayland.windowManager.hyprland.settings.monitor = lib.mkForce [
        "Virtual-1, 1920x1200@60, 0x0, 1"
      ];
    })
  ];

  system.stateVersion = lib.mkForce "24.11";
}
