{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # AI tools
    claude-code
    gemini-cli
    mcp-nixos

    # Apps
    bitwarden-desktop
    obsidian
    brave
    vesktop
    gimp
    obs-studio
    qbittorrent
    google-chrome
    jellyfin-desktop

    # KDE utilities (useful in both KDE and Hyprland)
    kdePackages.gwenview
    kdePackages.okular
    kdePackages.kcalc
    kdePackages.filelight
    kdePackages.discover

    # Dev tools
    glab
    shellcheck
    nodejs
    uv
  ];
}
