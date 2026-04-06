{ config, pkgs, ... }: {
  # Firefox via Home Manager module (better Wayland and profile integration)
  programs.firefox.enable = true;

  home.packages = with pkgs; [
    bitwarden-desktop      # Password manager
    obsidian               # Notes and knowledge base
    gimp                   # Image editing
    obs-studio             # Screen recording and streaming
    qbittorrent            # Torrent client
    jellyfin-desktop       # Jellyfin desktop client
    brave                  # Brave browser
    google-chrome          # Google Chrome (requires allowUnfree)
    vesktop                # Discord client (open-source, Wayland-native)

    # KDE apps
    kdePackages.gwenview   # Image viewer
    kdePackages.okular     # Document viewer (PDF, ebooks)
    kdePackages.kcalc      # Calculator
    kdePackages.filelight  # Disk usage visualizer
  ];
}
