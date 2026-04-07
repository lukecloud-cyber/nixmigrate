{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/desktop.nix
    ../../modules/system/audio.nix
    ../../modules/system/network.nix
  ];

  # Bootloader (BIOS — VM has no EFI partition)
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  # Standard kernel — no need for Zen in a VM
  # (uses default nixpkgs kernel)

  # Locale and timezone
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  # User account
  users.users.luke = {
    isNormalUser = true;
    description = "Luke";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" ];
    shell = pkgs.fish;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Nix settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # Weekly garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Fish must be enabled system-wide for it to work as a login shell
  programs.fish.enable = true;

  # QEMU guest agent — allows host to gracefully shutdown/freeze the VM
  services.qemuGuest.enable = true;

  # SPICE agent — clipboard sharing, auto-resize display in virt-manager
  services.spice-vdagentd.enable = true;

  system.stateVersion = "24.11";
}
