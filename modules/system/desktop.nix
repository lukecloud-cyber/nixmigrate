{ config, pkgs, ... }: {
  # X server base (required even for Wayland sessions on NixOS)
  services.xserver.enable = true;

  # SDDM display manager — shows both KDE and Hyprland as selectable sessions
  services.displayManager.sddm = {
    enable = true;
    # wayland.enable runs the SDDM greeter itself in Wayland (experimental).
    # Omitted here — KDE and Hyprland sessions are still Wayland regardless.
  };

  # Default session shown pre-selected at SDDM login
  services.displayManager.defaultSession = "plasma";

  # KDE Plasma 6
  services.desktopManager.plasma6.enable = true;

  # Hyprland — registers as a Wayland session in SDDM automatically
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;  # Proper systemd session integration (graphical-session.target etc.)
  };

  # Flatpak daemon
  services.flatpak.enable = true;

  # Add Flathub remote on first boot (system-wide, idempotent)
  # Note: runs as root, adds remote for all users on the machine.
  systemd.services.flatpak-add-flathub = {
    description = "Add Flathub remote for Flatpak";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo";
    };
  };

  # KDE Discover — GUI frontend for Flatpak/Flathub (replaces Bazzite Bazaar)
  environment.systemPackages = with pkgs; [
    kdePackages.discover
  ];

  # XDG portals — screen sharing, file pickers, screenshots per session
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-kde       # For KDE Plasma sessions
      xdg-desktop-portal-hyprland  # For Hyprland sessions
    ];
    config = {
      KDE = { default = [ "kde" ]; };
      hyprland = { default = [ "hyprland" ]; };
    };
  };
}
