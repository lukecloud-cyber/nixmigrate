{ config, pkgs, ... }: {
  # X server base (required even for Wayland sessions on NixOS)
  services.xserver.enable = true;

  # SDDM display manager — shows both KDE and Hyprland as login options
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # KDE Plasma 6
  services.desktopManager.plasma6.enable = true;

  # Hyprland — registers as a Wayland session in SDDM automatically
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # XWayland for legacy X11 app compatibility under KDE too
  programs.xwayland.enable = true;

  # Flatpak daemon
  services.flatpak.enable = true;

  # Add Flathub remote on first boot (idempotent — safe to run repeatedly)
  systemd.services.flatpak-add-flathub = {
    description = "Add Flathub remote for Flatpak";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" "flatpak.service" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo";
    };
  };

  # KDE Discover with Flatpak backend (GUI Flathub browser, replaces Bazzite Bazaar)
  environment.systemPackages = with pkgs; [
    kdePackages.discover
    libportal
    xdg-desktop-portal-kde
  ];

  # XDG portal — needed for Flatpak app integration with the desktop
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-kde ];
  };
}
