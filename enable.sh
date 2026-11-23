#!/usr/bin/env bash
set -euo pipefail

VLCRC="$HOME/.config/vlc/vlcrc"

pkill -x vlc 2>/dev/null || true
sleep 0.5

mkdir -p "$(dirname "$VLCRC")"
[ -f "$VLCRC" ] || touch "$VLCRC"
chmod 644 "$VLCRC"

set_vlc_opt() {
    local key="$1"
    local val="$2"
    if grep -Eq "^#?${key}=" "$VLCRC"; then
        sed -i "s|^#*${key}=.*|${key}=${val}|" "$VLCRC"
    else
        echo "${key}=${val}" >> "$VLCRC"
    fi
}

set_vlc_opt "extraintf" "luaintf"
set_vlc_opt "lua-intf" "vlc-auto-resume"
set_vlc_opt "qt-continue" "0"

chmod 444 "$VLCRC"

echo "Updated $VLCRC:"
grep -E '^(extraintf|lua-intf|qt-continue)=' "$VLCRC"
