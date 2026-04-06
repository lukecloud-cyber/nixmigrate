{ config, pkgs, ... }: {
  imports = [
    ./modules/home/shell.nix
    ./modules/home/cli.nix
    ./modules/home/dev.nix
    ./modules/home/apps.nix
  ];

  home.username = "luke";
  home.homeDirectory = "/home/luke";
  home.stateVersion = "24.11";
}
