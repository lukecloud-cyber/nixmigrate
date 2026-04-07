{ config, pkgs, lib, inputs, ... }: {
  imports = [
    ../hosts/nixpc/hardware-configuration.nix
  ];

  # ── Hydenix system options ──────────────────────────────────────────
  hydenix = {
    enable = true;
    hostname = "nixpc";
    timezone = "America/Chicago";
    locale = "en_US.UTF-8";
  };

  # Enable hydenix gaming (Steam, Lutris, MangoHud, Gamescope)
  hydenix.gaming.enable = true;

  # ── AMD GPU (hydenix doesn't cover this) ────────────────────────────
  hardware.enableRedistributableFirmware = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr    # ROCm OpenCL runtime (GPU compute)
    ];
    # RADV (Mesa) is the default Vulkan driver now; amdvlk was removed
  };

  environment.systemPackages = with pkgs; [
    vulkan-tools
    vulkan-loader
  ];

  # ── Gaming extras (beyond what hydenix provides) ────────────────────
  programs.gamemode.enable = true;
  hardware.steam-hardware.enable = true;
  programs.nix-ld.enable = true;

  # ── Virtualisation (hydenix doesn't include this) ───────────────────
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = false;
      swtpm.enable = true;
    };
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # ── User account ────────────────────────────────────────────────────
  users.users.luke = {
    isNormalUser = true;
    description = "Luke";
    initialPassword = "changeme";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" "libvirtd" ];
    shell = pkgs.fish;
  };

  # Fish must be enabled system-wide for login shell
  programs.fish.enable = true;

  # ── Nix settings ────────────────────────────────────────────────────
  # Note: allowUnfree and the hydenix overlay are applied by hydenix's
  # nix.nix module via nixpkgs.pkgs. Do NOT set nixpkgs.config or
  # nixpkgs.overlays here — it conflicts with the external instance.

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  system.stateVersion = lib.mkForce "24.11";
}
