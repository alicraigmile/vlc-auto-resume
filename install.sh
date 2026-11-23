#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="${1:-$SCRIPT_DIR/../src/vlc-auto-resume.lua}"
DEST_DIR="$HOME/.local/share/vlc/lua/intf"
DEST_FILE="$DEST_DIR/vlc-auto-resume.lua"

if [ ! -f "$SRC" ]; then
    echo "Error: Source file '$SRC' not found." >&2
    echo "Usage: $(basename "$0") [/path/to/vlc-auto-resume.lua]" >&2
    exit 1
fi

mkdir -p "$DEST_DIR"
install -m 644 "$SRC" "$DEST_FILE"

echo "Installed '$SRC' -> '$DEST_FILE' (mode 644)"
