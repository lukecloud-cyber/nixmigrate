{ config, pkgs, ... }: {
  imports = [];
  home.username = "luke";
  home.homeDirectory = "/home/luke";
  home.stateVersion = "24.11";
}
