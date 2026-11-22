#!/usr/bin/env bash
set -euo pipefail

DEST_DIR="$HOME/.local/share/vlc/lua/intf"
DEST_FILE="$DEST_DIR/auto_resume.lua"
STATE_FILE="$HOME/.local/share/vlc/last_played.txt"
VLCRC="$HOME/.config/vlc/vlcrc"

pkill -x vlc 2>/dev/null || true
sleep 0.5

# Disable custom interface and restore default Qt resume in vlcrc
if [ -f "$VLCRC" ]; then
    chmod 644 "$VLCRC"
    sed -i 's|^extraintf=.*|#extraintf=|' "$VLCRC"
    sed -i 's|^lua-intf=.*|#lua-intf=|' "$VLCRC"
    if grep -Eq '^#?qt-continue=' "$VLCRC"; then
        sed -i 's|^#*qt-continue=.*|qt-continue=1|' "$VLCRC"
    fi
fi

# Remove installed script and state file
rm -f "$DEST_FILE" "$STATE_FILE"

# Remove lua directories if empty
rmdir "$DEST_DIR" 2>/dev/null || true
rmdir "$HOME/.local/share/vlc/lua" 2>/dev/null || true

echo "Uninstalled auto_resume.lua and restored default VLC config."
