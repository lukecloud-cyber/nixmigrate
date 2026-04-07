{ config, pkgs, ... }: {
  imports = [
    ../../modules/home/shell.nix
    ../../modules/home/cli.nix
    ../../modules/home/dev.nix
    ../../modules/home/apps.nix
    ../../modules/home/backup.nix
  ];

  home.username = "luke";
  home.homeDirectory = "/home/luke";
  home.stateVersion = "24.11";

  # Force-overwrite files that conflict with existing unmanaged copies
  xdg.configFile."user-dirs.dirs".force = true;
  xdg.configFile."baloofilerc".force = true;
  xdg.configFile."mimeapps.list".force = true;
}
