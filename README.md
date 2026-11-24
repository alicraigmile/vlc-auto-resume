# VLC Auto Resume

A lightweight Lua interface script for VLC 3.x on Linux that tracks the last played local file or network stream (such as DLNA/UPnP) and prompts you to resume or restart when VLC opens with an empty playlist.

## Features

* **Works with local files and network streams:** Tracks both `file://` URIs and `http://` streams (e.g., MiniDLNA / UPnP) that VLC's built-in resume ignores.
* **Native startup dialog:** Uses `zenity` (GNOME/GTK) or `kdialog` (KDE) to show the media title, URI, and formatted timestamp (`MM:SS` or `h:MM:SS`) with three options:
  * **Continue at `<timestamp>`** — Loads the item and seeks to the saved position.
  * **Play from the start** — Loads the item from `00:00`.
  * **Cancel** — Dismisses the dialog and leaves the playlist empty without overwriting your saved state.
* **Non-intrusive:** Skips the prompt if VLC is launched with a file or URL from the command line or file manager.

## Repository Structure

```text
.
├── README.md
│── install.sh          # Installs vlc-auto-resume.lua to ~/.local/share/vlc/lua/intf/
│── enable.sh           # Configures ~/.config/vlc/vlcrc and locks it read-only
│── uninstall.sh        # Disables the interface, restores vlcrc, and removes files
│── vlc-auto-resume.lua # VLC Lua interface script
│── LICENSE             # Licencing details
└── TODO                # Things to do in the future


```

## Requirements

* **VLC 3.x** (native system package, e.g., Fedora RPM Fusion; Flatpak/Snap builds use sandboxed config paths)
* **`zenity`** or **`kdialog`** for the graphical startup prompt

## Installation

### Fedora

1. Enable the COPR repository, and install the RPM

   ```bash
   sudo dnf copr enable alicraigmile/vlc-auto-resume
   sudo dnf install vlc-auto-resume
   ```

2. Enable the interface in your ~/.config/clv/vlcrc (once per user)

   ```bash
   vlc-auto-resume-enable
   ```

### Debian / Raspbian

  ```curl -LO https://github.com/alicraigmile/vlc-auto-resume/releases/download/v0.2.9/vlc-auto-resume_0.2.9_all.deb
  apt-get install ./vlc-auto-resume_0.2.9_all.deb
  ```

### Local Installation

1. Make the scripts executable:

   ```bash
   chmod +x *.sh
   ```

2. Install the Lua interface script:

   ```bash
   ./install.sh
   ```

3. Enable the interface in VLC's configuration:

   ```bash
   ./enable.sh
   ```

> **Note:** `enable.sh` stops any running VLC processes, sets `extraintf=luaintf`, `lua-intf=vlc-auto-resume`, and `qt-continue=0` in `~/.config/vlc/vlcrc`, and sets `vlcrc` to read-only (`chmod 444`) so VLC's GUI does not strip `extraintf` on exit.

## Changing VLC Preferences Later

Because `~/.config/vlc/vlcrc` is locked read-only (`444`), changes made in VLC's Preferences GUI will not persist across restarts unless you temporarily unlock it:

```bash
chmod 644 ~/.config/vlc/vlcrc
# Launch VLC, adjust preferences, close VLC, then re-run:
./enable.sh
```

## Uninstallation

To stop VLC, restore default `vlcrc` settings (`qt-continue=1`, writable `644`), and remove the installed script and saved state:

```bash
./uninstall.sh
```

## How It Works

* While media is playing, `vlc-auto-resume.lua` polls VLC's active input every second and writes the URI, elapsed seconds, and resolved title to `~/.local/share/vlc/last_played.txt`.
* When VLC starts with an empty playlist, the script reads `last_played.txt` and invokes `zenity` (or `kdialog`) before starting playback based on your selection.

