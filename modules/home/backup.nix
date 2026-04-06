{ config, pkgs, lib, ... }: {
  home.packages = [ pkgs.rclone ];

  # Backup script placed at ~/backup_home.sh
  home.file."backup_home.sh" = {
    source = ../../scripts/backup_home.sh;
    executable = true;
  };

  # rclone exclude list — paths that are large, ephemeral, or re-pullable
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

  # Runs the backup script non-interactively (gum falls back to plain output automatically)
  systemd.user.services.rclone-backup = {
    Unit = {
      Description = "rclone home directory backup to Backblaze B2";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${config.home.homeDirectory}/backup_home.sh";
      # Provide an explicit PATH so rclone/gum/flatpak are found without a login shell
      Environment = "PATH=${lib.makeBinPath [ pkgs.rclone pkgs.gum pkgs.flatpak pkgs.bash ]}:/run/current-system/sw/bin";
    };
  };

  # Fires nightly at midnight; Persistent = true catches up if the machine was off
  systemd.user.timers.rclone-backup = {
    Unit.Description = "nightly rclone backup timer";
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
