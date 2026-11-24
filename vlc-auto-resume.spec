Name:           vlc-auto-resume
Version:        0.2.6
Release:        1%{?dist}
Summary:        VLC Lua interface extension to auto-resume local files and UPnP/DLNA streams

License:        MIT
URL:            https://github.com/alicraigmile/vlc-auto-resume
Source0:        %{url}/archive/v%{version}/%{name}-%{version}.tar.gz

BuildArch:      noarch
BuildRequires:  lua
BuildRequires:  groff
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
install -D -m 0644 vlc-auto-resume.lua %{buildroot}%{_datadir}/vlc/lua/intf/vlc-auto-resume.lua

# 2. Install the user-level enable script as a system command
install -D -m 0755 enable.sh %{buildroot}%{_bindir}/vlc-auto-resume-enable

# 3. Install man page
install -D -m 0644 enable.1 %{buildroot}%{_mandir}/man1/vlc-auto-resume-enable.1

%check
# 1. Verify bash script syntax
bash -n %{buildroot}%{_bindir}/vlc-auto-resume-enable

# 2. Verify Lua interface script exists, is non-empty, and syntax is correct
test -s %{buildroot}%{_datadir}/vlc/lua/intf/vlc-auto-resume.lua
luac -p %{buildroot}%{_datadir}/vlc/lua/intf/vlc-auto-resume.lua

# 3. Verify man page exists and parses without groff errors
test -s %{buildroot}%{_mandir}/man1/vlc-auto-resume-enable.1.gz
gzip -dc %{buildroot}%{_mandir}/man1/vlc-auto-resume-enable.1.gz | groff -man -Tutf8 -z

%files
%license LICENSE
%doc README.md
%{_datadir}/vlc/lua/intf/vlc-auto-resume.lua
%{_bindir}/vlc-auto-resume-enable
%{_mandir}/man1/vlc-auto-resume-enable.1*

%post
echo "========================================================================="
echo "vlc-auto-resume installed."
echo "To enable it for your user account and configure vlcrc, run:"
echo "  vlc-auto-resume-enable"
echo "========================================================================="

%changelog
* Tue Nov 24 2026 Ali Craigmile <ali@craigmile.com> - 0.2.6-1
- Release 0.2.6

* Tue Nov 24 2026 Ali Craigmile <ali@craigmile.com> - 0.2.5-1
- Release 0.2.5

* Tue Nov 24 2026 Ali Craigmile <ali@craigmile.com> - 0.2.4-1
- Release 0.2.4

* Tue Nov 24 2026 Ali Craigmile <ali@craigmile.com> - 0.2.3-1
- Release 0.2.3

* Tue Nov 24 2026 Ali Craigmile <ali@craigmile.com> - 0.2.2-1
- Release 0.2.2

* Tue Nov 24 2026 Ali Craigmile <ali@craigmile.com> - 0.2.1-1
- Release 0.2.1

* Tue Nov 24 2026 Ali Craigmile <ali@craigmile.com> - 0.2.0-1
- Release 0.2.0

* Tue Nov 24 2026 Ali Craigmile <ali@craigmile.com> - 0.1.0-1
- Release 0.1.0

* Mon Nov 23 2026 Ali Craigmile <ali@craigmile.com> - 0.0.1-1
- Initial RPM package release
