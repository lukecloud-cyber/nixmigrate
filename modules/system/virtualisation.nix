{ config, pkgs, ... }: {
  # libvirt — QEMU/KVM virtual machine management
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = false;
      swtpm.enable = true;   # TPM emulation (needed for Windows 11 VMs)
    };
  };

  # virt-manager GUI must be a system package to access the libvirtd socket
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
  ];

  # Podman — rootless container runtime used by Podman Desktop
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;   # Allows `docker` CLI to route through Podman
    defaultNetwork.settings.dns_enabled = true;
  };

  # luke must be in the libvirtd group to manage VMs without sudo
  users.users.luke.extraGroups = [ "libvirtd" ];
}
