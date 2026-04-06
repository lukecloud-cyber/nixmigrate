{ config, pkgs, ... }: {
  # Steam — NixOS module handles 32-bit libs, Proton, and udev rules automatically
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
    gamescopeSession.enable = true;
  };

  # Steam controller and hardware udev rules
  hardware.steam-hardware.enable = true;

  # GameMode — lets games request CPU/GPU performance governor on demand
  programs.gamemode.enable = true;

  # Gamescope — Valve's micro-compositor (upscaling, frame limiting, HDR)
  programs.gamescope = {
    enable = true;
    capSysNice = true;  # Allows gamescope to raise process priority for smoother frametimes
  };

  # nix-ld — provides a dynamic linker shim so pre-compiled binaries
  # (Proton, Steam runtime, some game executables) can find system libraries.
  # Without this, many Proton games fail to launch on NixOS.
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    mangohud      # In-game performance overlay (FPS, VRAM, temps)
    lutris        # Game launcher for GOG, Epic, Battle.net, etc.
    protontricks  # Helper for Proton/Wine prefix tweaks per-game
    protonup-qt   # GUI for managing Proton-GE versions
  ];
}
