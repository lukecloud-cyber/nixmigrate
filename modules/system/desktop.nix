{ config, pkgs, ... }: {
  # Persist secrets (browser logins, gh tokens, etc.) across reboots
  services.gnome.gnome-keyring.enable = true;

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

  # Hint Electron apps (Vesktop, Obsidian, Bitwarden, etc.) to use Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # KDE Discover — GUI frontend for Flatpak/Flathub (replaces Bazzite Bazaar)
  environment.systemPackages = with pkgs; [
    kdePackages.discover
    kitty  # Default terminal in Hyprland's built-in keybinds
  ];

  # XDG portals — screen sharing, file pickers, screenshots per session
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde  # For KDE Plasma sessions
      xdg-desktop-portal-gtk  # File picker fallback (XDPH doesn't implement one)
      # xdg-desktop-portal-hyprland is added automatically by programs.hyprland.enable
    ];
    config = {
      KDE = { default = [ "kde" ]; };
      hyprland = { default = [ "hyprland" "gtk" ]; };
    };
  };
}
