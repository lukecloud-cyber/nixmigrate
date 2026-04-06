{ config, pkgs, ... }: {
  networking = {
    hostName = "nixpc";
    networkmanager.enable = true;
    firewall.enable = true;
  };

  # KDE Connect — phone/desktop integration; opens its firewall ports automatically
  programs.kdeconnect.enable = true;

  # systemd-resolved for DNS
  services.resolved.enable = true;
}
