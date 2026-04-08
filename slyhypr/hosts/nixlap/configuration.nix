{ lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./host-packages.nix
    ../../modules # Dendritic hub — pulls in all core, desktop, and program modules
  ];

  # ── AMD GPU extras (beyond what the amdgpu module provides) ─────────
  hardware.graphics = {
    enable32Bit = true;
    extraPackages = with pkgs; [ rocmPackages.clr ];
  };

  # ── KDE Plasma 6 alongside Hyprland (selectable at SDDM) ───────────
  services.desktopManager.plasma6.enable = true;
  services.power-profiles-daemon.enable = false; # Conflicts with TLP

  # ── Home Manager overrides ──────────────────────────────────────────
  home-manager.sharedModules = [
    (_: {
      home.stateVersion = lib.mkForce "24.11";
    })
  ];

  # ── Fish shell (zsh execs into fish after fastfetch) ─────────────────
  programs.fish.enable = true;
  programs.fish.interactiveShellInit = "fastfetch";
  system.stateVersion = lib.mkForce "24.11";
}
