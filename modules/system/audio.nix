{ config, pkgs, ... }: {
  # Disable PulseAudio — PipeWire replaces it
  services.pulseaudio.enable = false;

  # Real-time audio scheduling (reduces latency for audio apps and games)
  security.rtkit.enable = true;

  # PipeWire — handles all audio routing
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;   # 32-bit ALSA for games and Wine
    pulse.enable = true;        # PulseAudio compatibility layer
    jack.enable = true;         # JACK compatibility layer
    wireplumber.enable = true;  # WirePlumber session manager
  };
}
