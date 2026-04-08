{ pkgs, ... }:
{
  # TODO: review
  programs = {
    fuse.userAllowOther = true;
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    appimage-run # Needed For AppImage Support
    killall # For Killing All Instances Of Programs
    lm_sensors # Used For Getting Hardware Temps
    gnome-disk-utility # Disk Partitioning and Mounting Utility
    rclone # Cloning Utility
    jq # Json Formatting Utility
    bibata-cursors
    sddm-astronaut # Sddm Theme (Overlayed)
    kdePackages.qtsvg # Sddm Dependency
    kdePackages.qtmultimedia # Sddm Dependency
    kdePackages.qtvirtualkeyboard # Sddm Dependency
    fzf # Fuzzy Finder
    fd # Better Find
    git # Git
    zoxide # Fast directory jumping (z/cd replacement)
    gh # Github Authentication Client
    libjxl # Support for JXL Images
    microfetch # Small fetch (Blazingly fast)
    nix-prefetch-scripts # Find Hashes/Revisions of Nix Packages
    ripgrep # Improved Grep
    tldr # Improved Man
    unrar # Tool For Handling .rar Files
    unzip # Tool For Handling .zip Files
    bat # Cat with syntax highlighting and git integration
    delta # Beautiful git diff pager
    dust # Intuitive disk usage visualization
    duf # Clean df replacement
    sd # Simpler sed for find-and-replace
    procs # Modern ps with color and tree view
    gping # Ping with live graph
    hyperfine # Command benchmarking
    tokei # Code statistics by language
    hexyl # Colored hex viewer
    choose # Simple column selection (cut/awk replacement)
    # aider-chat # AI in terminal (Optional: Client only)
    # cmatrix # Matrix Movie Effect In Terminal
    # cowsay # Great Fun Terminal Program
    # dysk # Disk space util nice formattting
    # ffmpeg # Terminal Video / Audio Editing
    # gemini-cli # CLI AI client ONLY (optional)
    # glxinfo # needed for inxi diag util
    # inxi # CLI System Information Tool
    # libsForQt5.qt5.qtgraphicaleffects # Sddm Dependency (Old)
    # libnotify # For Notifications
    # lolcat # Add Colors To Your Terminal Command Output
    # lshw # Detailed Hardware Information
    # mpv # Incredible Video Player
    # ncdu # Disk Usage Analyzer With Ncurses Interface
    # nixfmt-rfc-style # Nix Formatter
    # nwg-displays # configure monitor configs via GUI
    # onefetch # provides zsaneyos build info on current system
    # pavucontrol # For Editing Audio Levels & Devices
    # pciutils # Collection Of Tools For Inspecting PCI Devices
    # picard # For Changing Music Metadata & Getting Cover Art
    # pkg-config # Wrapper Script For Allowing Packages To Get Info On Others
    # rhythmbox # audio player
    # socat # Needed For Screenshots
    # usbutils # Good Tools For USB Devices
    # uwsm # Universal Wayland Session Manager (optional must be enabled)
    # v4l-utils # Used For Things Like OBS Virtual Camera
    # warp-terminal # Terminal with AI support build in
    # waypaper # Change wallpaper
    # wget # Tool For Fetching Files With Links
    # ytmdl # Tool For Downloading Audio From YouTube

    # devenv
    # devbox
    # shellify
  ];
}
