{ config, pkgs, ... }: {
  imports = [
    ./modules/home/dev.nix
  ];
  home.username = "luke";
  home.homeDirectory = "/home/luke";
  home.stateVersion = "24.11";
}
