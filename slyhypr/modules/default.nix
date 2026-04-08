{ host, lib, ... }:
let
  vars = import ../hosts/${host}/variables.nix;
in
{
  imports = [
    # Core Modules (Don't change unless you know what you're doing)
    ./scripts
    ./core/boot.nix
    ./core/bash.nix
    ./core/zsh.nix
    ./core/starship.nix
    ./core/fonts.nix
    ./core/hardware.nix
    ./core/network.nix
    ./core/dns.nix
    ./core/nh.nix
    ./core/packages.nix
    ./core/printing.nix
    ./core/sddm.nix
    ./core/security.nix
    ./core/services.nix
    ./core/syncthing.nix
    ./core/system.nix
    ./core/users.nix
    # ./core/flatpak.nix
    # ./core/virtualisation.nix
    # ./core/dlna.nix

    # Optional
    ./hardware/drives.nix
    ./hardware/video/${vars.videoDriver}.nix # Enable gpu drivers defined in variables.nix
    ./desktop/${vars.desktop} # Set window manager defined in variables.nix
    ./programs/browser/${vars.browser} # Set browser defined in variables.nix
    ./programs/terminal/${vars.terminal} # Set terminal defined in variables.nix
    ./programs/editor/${vars.editor} # Set editor defined in variables.nix
    ./programs/cli
    ./programs/media/discord.nix
    ./programs/media/spicetify.nix
    # ./programs/media/youtube-music.nix
    # ./programs/media/thunderbird.nix
    # ./programs/media/obs-studio.nix
    ./programs/media/mpv.nix
    ./programs/misc/tlp.nix
    ./programs/misc/thunar.nix
    ./programs/misc/lact.nix # GPU fan, clock and power configuration
  ]
  ++ lib.optional (vars.games == true) ./core/games.nix;
}
