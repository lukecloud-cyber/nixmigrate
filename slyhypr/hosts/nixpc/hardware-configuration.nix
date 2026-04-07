# =============================================================================
# PLACEHOLDER — DO NOT USE THIS FILE AS-IS
# =============================================================================
# When you boot the NixOS installer on your target machine, run:
#
#   nixos-generate-config --show-hardware-config
#
# Copy the output over this entire file. It will detect your actual:
#   - Disk UUIDs and filesystem layout
#   - CPU type and kernel modules
#   - NVMe/SATA controller drivers
#
# The AMD GPU is handled in modules/hardware/video/amdgpu.nix — not here.
# =============================================================================

{ config, lib, pkgs, modulesPath, ... }: {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # TODO: Replace with real UUIDs from nixos-generate-config
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/REPLACE-WITH-ROOT-UUID";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/REPLACE-WITH-BOOT-UUID";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
