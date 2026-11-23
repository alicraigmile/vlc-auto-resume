Name:           vlc-auto-resume
Version:        0.0.1
Release:        1%{?dist}
Summary:        VLC Lua interface extension to auto-resume local files and UPnP/DLNA streams

License:        MIT
URL:            https://github.com/alicraigmile/vlc-auto-resume
Source0:        %{name}-%{version}.tar.gz

BuildArch:      noarch
Requires:       vlc
Requires:       zenity

%description
A Lua interface extension for VLC 3.x that tracks playback positions for both
local media files and UPnP/DLNA streams (such as MiniDLNA), prompting the user
via Zenity on startup to resume, restart, or cancel.

%prep
%autosetup

%build
# Pure Lua and Bash scripts; no compilation required.

%install
# 1. Install the Lua interface script system-wide
install -D -m 0644 src/vlc-auto-resume.lua %{buildroot}%{_datadir}/vlc/lua/intf/vlc-auto-resume.lua

# 2. Install the user-level enable script as a system command
install -D -m 0755 scripts/enable.sh %{buildroot}%{_bindir}/vlc-auto-resume-enable

%files
%license LICENSE
%doc README.md
%{_datadir}/vlc/lua/intf/vlc-auto-resume.lua
%{_bindir}/vlc-auto-resume-enable

%post
echo "========================================================================="
echo "vlc-auto-resume installed."
echo "To enable it for your user account and configure vlcrc, run:"
echo "  vlc-auto-resume-enable"
echo "========================================================================="

%changelog
* Mon Nov 23 2026 Ali Craigmile <ali@craigmile.com> - 1.0.0-1
- Initial RPM package release
