{ config, pkgs, lib, ... }: {
  # Redistributable firmware (AMD CPU microcode + GPU firmware)
  hardware.enableRedistributableFirmware = true;

  # AMD GPU — open-source amdgpu driver is loaded automatically via kernel.
  # The graphics block below enables OpenGL/Vulkan userspace.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;  # Required for Steam and Proton 32-bit games

    extraPackages = with pkgs; [
      amdvlk                   # AMD open Vulkan driver (alternative to radv in Mesa)
      rocmPackages.clr         # ROCm OpenCL runtime (GPU compute)
    ];

    # 32-bit Vulkan support for Proton
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];
  };

  # Vulkan tools available system-wide
  environment.systemPackages = with pkgs; [
    vulkan-tools
    vulkan-loader
  ];
}
