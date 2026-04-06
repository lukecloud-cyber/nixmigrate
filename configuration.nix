{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./modules/system/hardware.nix
  ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "nixpc";
  users.users.luke = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
  system.stateVersion = "24.11";
}
