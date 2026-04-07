{
  username = "luke";

  # Desktop Environment
  desktop = "hyprland"; # hyprland, i3, gnome, plasma6

  # Theme & Appearance
  bar = "waybar"; # waybar, hyprpanel, noctalia
  waybarTheme = "stylish"; # stylish, minimal
  sddmTheme = "astronaut"; # astronaut, black_hole, purple_leaves, jake_the_dog, hyprland_kath
  defaultWallpaper = "galaxy.webp"; # Change with SUPER + SHIFT + W (Hyprland)
  hyprlockWallpaper = "galaxy.webp";

  # Default Applications
  terminal = "kitty"; # kitty, alacritty
  editor = "nixvim"; # nixvim, vscode, helix, doom-emacs, nvchad, neovim
  browser = "firefox"; # zen-beta, firefox, floorp
  tuiFileManager = "yazi"; # yazi, lf
  shell = "zsh"; # zsh, bash
  games = false; # VM — no gaming

  # Hardware
  hostname = "nixvm";
  bluetoothSupport = false;

  # Localization
  timezone = "America/Chicago";
  locale = "en_US.UTF-8";
  clock24h = false;
  kbdLayout = "us";
  kbdVariant = "";
  consoleKeymap = "us";
}
