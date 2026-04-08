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

    # Desktop & programs
    ../../modules/hardware/video/${vars.videoDriver}.nix
    ../../modules/desktop/${vars.desktop}
    ../../modules/programs/browser/${vars.browser}
    ../../modules/programs/terminal/${vars.terminal}
    ../../modules/programs/editor/${vars.editor}
    ../../modules/programs/cli/${vars.tuiFileManager}
    ../../modules/programs/cli/tmux
    ../../modules/programs/cli/direnv
    ../../modules/programs/cli/lazygit
    ../../modules/programs/cli/cava
    ../../modules/programs/cli/btop
    ../../modules/programs/media/discord
    ../../modules/programs/media/spicetify
    ../../modules/programs/media/mpv
    ../../modules/programs/misc/thunar
  ];

  # ── AMD GPU extras (beyond what the amdgpu module provides) ─────────
  hardware.graphics = {
    enable32Bit = true;
    extraPackages = with pkgs; [ rocmPackages.clr ];
  };

  # ── KDE Plasma 6 alongside Hyprland (selectable at SDDM) ───────────
  services.desktopManager.plasma6.enable = true;

  # ── Home Manager overrides ──────────────────────────────────────────
  home-manager.sharedModules = [
    (_: {
      home.stateVersion = lib.mkForce "24.11";
    })
  ];

  # ── Fish shell (in addition to zsh from variables) ──────────────────
  programs.fish.enable = true;

  system.stateVersion = lib.mkForce "24.11";
}
