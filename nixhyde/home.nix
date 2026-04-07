{ config, pkgs, lib, inputs, ... }: {
  imports = [
    # Hydenix home-manager modules (Hyprland rice, waybar, themes, etc.)
    inputs.hydenix.homeModules.default
  ];

  home.username = "luke";
  home.homeDirectory = "/home/luke";

  # ── Hydenix HM options ──────────────────────────────────────────────
  hydenix.hm = {
    enable = true;

    # Shell: enable fish (your primary shell), keep starship via Hyde
    shell = {
      enable = true;
      fish.enable = true;
      starship.enable = true;
      fastfetch.enable = true;
    };

    # Editors: disable hydenix's neovim/vim to avoid conflicting with LazyVim.
    # Set default to "nvim" so EDITOR/VISUAL point to neovim.
    editors = {
      enable = true;
      neovim = false;
      vim = false;
      vscode.enable = true;
      default = "nvim";
    };

    # Git: use hydenix's git module with your details
    git = {
      enable = true;
      name = "luke";
      email = "you@example.com";
    };

    # Theme — pick one to start with, switch later with `hydectl`
    theme = {
      enable = true;
      active = "Catppuccin Mocha";
    };

    # Hyprland config
    hyprland.enable = true;
  };

  # ── Your shell extras (on top of hydenix fish) ─────────────────────
  # HM merges these with hydenix's fish config automatically.

  programs.tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi";
    prefix = "C-a";
    terminal = "tmux-256color";
    tmuxinator.enable = true;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
    ];
  };

  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      auto_sync = false;
      update_check = false;
    };
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    nix-direnv.enable = true;
  };

  # ── Neovim + LazyVim (yours, not hydenix's) ────────────────────────
  programs.neovim = {
    enable = true;
    defaultEditor = false;  # hydenix.hm.editors.default handles EDITOR
    viAlias = true;
    vimAlias = true;
  };

  xdg.configFile."nvim" = {
    source = ./dotfiles/nvim;
    recursive = true;
  };

  # ── CLI tools ───────────────────────────────────────────────────────
  home.packages = with pkgs; [
    # Modern CLI replacements
    fd
    ripgrep
    lf
    yq
    tealdeer
    trash-cli
    gum
    chafa
    w3m
    television

    # Dev tools
    glab
    shellcheck
    nodejs
    python3
    uv
    claude-code
    gemini-cli
    mcp-nixos

    # Gaming extras
    protontricks
    protonup-qt

    # Virtualisation GUIs
    virt-manager
    virt-viewer

    # Apps
    bitwarden-desktop
    obsidian
    gimp
    obs-studio
    qbittorrent
    jellyfin-desktop
    brave
    google-chrome
    vesktop
    kdePackages.gwenview
    kdePackages.okular
    kdePackages.kcalc
    kdePackages.filelight
  ];

  # Fish aliases for your CLI tools (mkForce where hydenix also defines them)
  programs.fish.shellAliases = {
    ls   = lib.mkForce "eza --icons";
    ll   = lib.mkForce "eza -la --icons";
    lt   = lib.mkForce "eza --tree --icons";
    cat  = "bat";
    find = "fd";
    grep = "rg";
    rm   = "trash";
  };

  # GitHub CLI
  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };

  # Firefox (hydenix also enables this, HM merges cleanly)
  programs.firefox.enable = true;

  # ── Backup (rclone to Backblaze B2) ────────────────────────────────
  home.file."backup_home.sh" = {
    source = ./scripts/backup_home.sh;
    executable = true;
  };

  home.file.".config/rclone/exclude.txt".text = ''
    /Games/**
    /media/**
    /.cache/**
    /.local/share/Steam/steamapps/common/**
    /.steam/**
    /.var/app/*/cache/**
    /.pki/**
    /.npm/**
    /.cargo/registry/**
    /node_modules/**
    /pass/**
    /.local/share/containers/**
    /Downloads/**
    .DS_Store
  '';

  systemd.user.services.rclone-backup = {
    Unit = {
      Description = "rclone home directory backup to Backblaze B2";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${config.home.homeDirectory}/backup_home.sh";
      Environment = "PATH=${lib.makeBinPath [ pkgs.rclone pkgs.gum pkgs.flatpak pkgs.bash ]}:/run/current-system/sw/bin";
    };
  };

  systemd.user.timers.rclone-backup = {
    Unit.Description = "nightly rclone backup timer";
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  home.stateVersion = lib.mkForce "24.11";
}
