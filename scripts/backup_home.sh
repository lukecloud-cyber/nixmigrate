#!/bin/bash
# ~/backup_home.sh
# rclone backup script combining gum animations with live data

SOURCE_DIR="$HOME"
REMOTE_DEST="vault:backup/home"
REMOTE_ROOT="${REMOTE_DEST%%:*}:"
EXCLUDE_FILE="$HOME/.config/rclone/exclude.txt"
LOG_FILE="$HOME/.local/state/rclone-backup.log"
APP_LIST_DIR="$HOME/.local/state/app-lists"

mkdir -p "$(dirname "$LOG_FILE")" "$APP_LIST_DIR"

# Snapshot installed Flatpak apps so the backup always contains a current app list
snapshot_app_lists() {
    if command -v flatpak &> /dev/null; then
        flatpak list --app --columns=application > "$APP_LIST_DIR/flatpak-apps.txt"
    fi
}

DRY_RUN=false
DRY_RUN_TEXT=""

for arg in "$@"; do
    if [[ "$arg" == "--dry-run" ]]; then
        DRY_RUN=true
        DRY_RUN_TEXT=" (DRY RUN)"
    fi
done

RCLONE_OPTS=(
    "$SOURCE_DIR"
    "$REMOTE_DEST"
    "--exclude-from" "$EXCLUDE_FILE"
    "--links"
    "--fast-list"
    "--progress"
    "--stats" "1s"
    "--stats-one-line-date"
    "--log-file" "$LOG_FILE"
    "--log-level" "INFO"
)

if [[ "$DRY_RUN" == true ]]; then
    RCLONE_OPTS+=("--dry-run")
fi

# Fallback if gum is not installed or if running non-interactively (e.g., systemd timer)
if ! command -v gum &> /dev/null || [ ! -t 1 ]; then
    snapshot_app_lists
    rclone sync "${RCLONE_OPTS[@]}"
    exit $?
fi

clear
HEADER_TEXT="🚀 BACKUP ENGINE: INITIALIZING$DRY_RUN_TEXT"
gum style --foreground 212 --border-foreground 212 --border double --align center --width 60 "$HEADER_TEXT"
echo ""

if command -v flatpak &> /dev/null; then
    if gum spin --spinner dot --title "Capturing Flatpak apps..." -- bash -c "flatpak list --app --columns=application > '$APP_LIST_DIR/flatpak-apps.txt'"; then
        FLATPAK_COUNT=$(wc -l < "$APP_LIST_DIR/flatpak-apps.txt")
        gum log --level info "Flatpak list saved — $FLATPAK_COUNT apps"
    else
        gum log --level warn "Flatpak snapshot failed — continuing anyway"
    fi
fi
echo ""

if ! gum spin --spinner pulse --title "Verifying connection to Backblaze B2..." -- rclone lsf "$REMOTE_ROOT" --max-depth 1 > /dev/null 2>&1; then
    gum style --foreground 9 --border-foreground 9 --border rounded --align center --width 60 "❌ CONNECTION FAILED!"
    gum log --level error "Could not connect to remote ($REMOTE_ROOT). Please check your network and rclone config."
    exit 1
fi
gum log --level info "Connection established. Starting data stream..."
echo ""

rclone sync "${RCLONE_OPTS[@]}"

EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    SUCCESS_TEXT="✅ BACKUP COMPLETED SUCCESSFULLY!$DRY_RUN_TEXT"
    gum style --foreground 10 --border-foreground 10 --border rounded --align center --width 60 "$SUCCESS_TEXT"
    if [[ "$DRY_RUN" == true ]]; then
        gum log --level info "Dry run finished. No files were modified."
    else
        gum log --level info "Your files are safe in the cloud."
    fi
else
    gum style --foreground 9 --border-foreground 9 --border rounded --align center --width 60 "❌ BACKUP FAILED!"
    gum log --level error "Status Code: $EXIT_CODE"
    gum log --level warn "Possible Cause: Backblaze Storage Cap Exceeded or Network Error."
    gum log --level info "Check log at: $LOG_FILE"
    gum style --foreground 240 "(Check your B2 Dashboard: https://secure.backblaze.com/b2_caps_alerts.htm)"
fi
