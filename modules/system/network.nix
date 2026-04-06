{ config, pkgs, ... }: {
  networking = {
    hostName = "nixpc";  # Update to your actual hostname
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";  # Delegate DNS to systemd-resolved via stub resolver
    };
    firewall.enable = true;
  };

  # KDE Connect — phone/desktop integration; opens its firewall ports automatically
  programs.kdeconnect.enable = true;

  # systemd-resolved for DNS
  services.resolved.enable = true;
}
