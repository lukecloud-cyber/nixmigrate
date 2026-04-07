{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/hardware.nix
    ../../modules/system/desktop.nix
    ../../modules/system/audio.nix
    ../../modules/system/gaming.nix
    ../../modules/system/virtualisation.nix
    ../../modules/system/network.nix
  ];

  # Bootloader (EFI — change to boot.loader.grub if your machine uses BIOS)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Linux Zen kernel — gaming-tuned patches, lower latency scheduler
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # Locale and timezone — update timezone to your actual location
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  # User account
  users.users.luke = {
    isNormalUser = true;
    description = "Luke";
    initialPassword = "changeme";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" "libvirtd" ];
    shell = pkgs.fish;
  };

  # Allow unfree packages (Steam, Chrome, etc.)
  nixpkgs.config.allowUnfree = true;

  # Nix settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # Weekly garbage collection — removes generations older than 30 days
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Fish must be enabled system-wide for it to work as a login shell
  programs.fish.enable = true;

  system.stateVersion = "24.11";
}
