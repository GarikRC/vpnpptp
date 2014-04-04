%define _enable_debug_packages %{nil}
%define debug_package %{nil}

Summary: Tools for setup and control VPN via PPTP/L2TP/OpenL2TP
Name: vpnpptp
Version: 0.3.9
Release: %mkrel 1
License: GPL2+
Group: System/Configuration/Networking
Url: http://code.google.com/p/vpnpptp

Source0: vpnpptp-src-%{version}.tar.gz
Source1: vpnpptp.pm
Source2: vpnmcc.pm

BuildRequires: fpc-src >= 2.6.2, fpc >= 2.6.2, lazarus >= 1.0.12
#Please comment all dependencies if you builds not for repo
#You can use xroot/kdesu/gksu/beesu
Requires: xroot
Requires: pptp-linux
Requires: xl2tpd >= 1.3.6
Requires: openl2tp
#For mii-tool
Suggests: net-tools
#For host
Suggests: bind-utils
#For sudo and xsudo
Suggests: xsudo
#For dhclient
Suggests: dhcp-client
Suggests: net_monitor
Suggests: vnstat

Provides: vpnpptp-allde
Provides: vpnpptp-kde

%description
Tools for easy and quick setup and control VPN via PPTP/L2TP/OpenL2TP.

%prep
%setup -q -n vpnpptp-src-%{version}

%build
./compile.sh

%install
mkdir -p %{buildroot}%{_datadir}/vpnpptp
mkdir -p %{buildroot}%{_datadir}/vpnpptp/scripts
mkdir -p %{buildroot}%{_datadir}/vpnpptp/wiki
mkdir -p %{buildroot}%{_datadir}/vpnpptp/lang
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_datadir}/applications
mkdir -p %{buildroot}%{_datadir}/pixmaps
mkdir -p %{buildroot}/lib/libDrakX/network/connection

cp -f ./vpnpptp/vpnpptp %{buildroot}%{_bindir}
cp -f ./ponoff/ponoff %{buildroot}%{_bindir}
cp -f ./vpnmcc/vpnmcc %{buildroot}%{_bindir}
cp -f ./ponoff.png %{buildroot}%{_datadir}/pixmaps/
cp -f ./vpnpptp.png %{buildroot}%{_datadir}/pixmaps/
chmod 0644 %{buildroot}%{_datadir}/pixmaps/ponoff.png
chmod 0644 %{buildroot}%{_datadir}/pixmaps/vpnpptp.png
cp -f ./*.ico %{buildroot}%{_datadir}/vpnpptp
cp -f ./vpnlinux %{buildroot}%{_bindir}
cp -rf ./scripts %{buildroot}%{_datadir}/vpnpptp/
cp -rf ./wiki %{buildroot}%{_datadir}/vpnpptp/
cp -rf ./lang %{buildroot}%{_datadir}/vpnpptp/

install -dm 755 %{buildroot}%{_datadir}/applications
cat > ponoff.desktop << EOF

[Desktop Entry]
Encoding=UTF-8
GenericName=VPN PPTP/L2TP/OpenL2TP Control
GenericName[ru]=Управление соединением VPN PPTP/L2TP/OpenL2TP
GenericName[uk]=Керування з'єднанням VPN PPTP/L2TP/OpenL2TP
Name=ponoff
Name[ru]=ponoff
Name[uk]=ponoff
Exec=ponoff
Comment=Control VPN via PPTP/L2TP/OpenL2TP
Comment[ru]=Управление соединением VPN через PPTP/L2TP/OpenL2TP
Comment[uk]=Керування з'єднанням VPN через PPTP/L2TP/OpenL2TP
Icon=/usr/share/pixmaps/ponoff.png
Type=Application
Categories=GTK;System;Monitor;X-MageiaLinux-CrossDesktop;
X-KDE-autostart-after=kdesktop
StartupNotify=false
EOF
install -m 0644 ponoff.desktop \
%{buildroot}%{_datadir}/applications/ponoff.desktop

cat > vpnpptp.desktop << EOF

[Desktop Entry]
Encoding=UTF-8
GenericName=VPN PPTP/L2TP/OpenL2TP Setup
GenericName[ru]=Настройка соединения VPN PPTP/L2TP/OpenL2TP
GenericName[uk]=Налаштування з’єднання VPN PPTP/L2TP/OpenL2TP
Name=vpnpptp
Name[ru]=vpnpptp
Name[uk]=vpnpptp
Exec=vpnpptp
Comment=Setup VPN via PPTP/L2TP/OpenL2TP
Comment[ru]=Настройка соединения VPN PPTP/L2TP/OpenL2TP
Comment[uk]=Налаштування з’єднання VPN PPTP/L2TP/OpenL2TP
Icon=/usr/share/pixmaps/vpnpptp.png
Type=Application
Categories=GTK;System;Monitor;X-MageiaLinux-CrossDesktop;
StartupNotify=false
EOF
install -m 0644 vpnpptp.desktop \
%{buildroot}%{_datadir}/applications/vpnpptp.desktop

install -pm0644 -D %{SOURCE1} %{buildroot}/usr/lib/libDrakX/network/vpn/vpnpptp.pm
install -pm0644 -D %{SOURCE2} %{buildroot}/usr/lib/libDrakX/network/vpn/vpnmcc.pm

%files
%{_bindir}/vpnpptp
%{_bindir}/ponoff
%{_bindir}/vpnlinux
%{_bindir}/vpnmcc
%{_datadir}/vpnpptp/lang
%{_datadir}/pixmaps/ponoff.png
%{_datadir}/pixmaps/vpnpptp.png
%{_datadir}/vpnpptp/*.ico
%{_datadir}/vpnpptp/scripts
%{_datadir}/vpnpptp/wiki
%{_datadir}/applications/ponoff.desktop
%{_datadir}/applications/vpnpptp.desktop
%{_prefix}/lib/libDrakX/network/vpn/vpnpptp.pm
%{_prefix}/lib/libDrakX/network/vpn/vpnmcc.pm

%changelog
