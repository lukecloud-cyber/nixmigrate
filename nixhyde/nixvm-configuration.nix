{ config, pkgs, lib, inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  # ── Hydenix system options ──────────────────────────────────────────
  hydenix = {
    enable = true;
    hostname = "nixvm";
    timezone = "America/Chicago";
    locale = "en_US.UTF-8";
  };

  # ── Boot (BIOS VM — override hydenix's default systemd-boot) ───────
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.grub.enable = lib.mkForce true;
  boot.loader.grub.device = "/dev/vda";

  # ── QEMU/SPICE guest agents ────────────────────────────────────────
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  # ── User account ────────────────────────────────────────────────────
  users.users.luke = {
    isNormalUser = true;
    description = "Luke";
    initialPassword = "changeme";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" ];
    shell = pkgs.fish;
  };

  # Fish must be enabled system-wide for login shell
  programs.fish.enable = true;

  # ── Nix settings ────────────────────────────────────────────────────
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  system.stateVersion = lib.mkForce "24.11";
}
