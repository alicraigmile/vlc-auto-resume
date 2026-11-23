#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="${1:-$SCRIPT_DIR/../src/auto_resume.lua}"
DEST_DIR="$HOME/.local/share/vlc/lua/intf"
DEST_FILE="$DEST_DIR/auto_resume.lua"

if [ ! -f "$SRC" ]; then
    echo "Error: Source file '$SRC' not found." >&2
    echo "Usage: $(basename "$0") [/path/to/auto_resume.lua]" >&2
    exit 1
fi

mkdir -p "$DEST_DIR"
install -m 644 "$SRC" "$DEST_FILE"

echo "Installed '$SRC' -> '$DEST_FILE' (mode 644)"
