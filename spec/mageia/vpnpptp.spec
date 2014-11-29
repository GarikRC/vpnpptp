%define _enable_debug_packages %{nil}
%define debug_package %{nil}

Summary: Tools for setup and control VPN via PPTP/L2TP/OpenL2TP
Name: vpnpptp
Version: 0.3.9
Release: %mkrel 1
License: GPLv2+
Group: System/Networking
Url: http://code.google.com/p/vpnpptp

Source0: %{name}-src-%{version}.tar.gz
Source1: %{name}.pm
Source2: vpnmcc.pm

BuildRequires: fpc-src >= 2.6.2
BuildRequires: fpc >= 2.6.2
#You need lazarus with fix http://bugs.freepascal.org/view.php?id=23217
BuildRequires: lazarus >= 1.0.12
#Please comment all dependencies if you builds not for repo
#You can use xroot/kdesu/gksu/beesu/polkit
Requires: polkit
Requires: pptp-linux
Requires: xl2tpd >= 1.3.6
Requires: openl2tp
#For mii-tool
Recommends: net-tools
#For host
Recommends: bind-utils
#For sudo and xsudo
Recommends: xsudo
#For dhclient
Recommends: dhcp-client
Recommends: net_monitor
Recommends: vnstat

Provides: %{name}-allde = %{version}
Provides: %{name}-kde = %{version}

%description
Tools for easy and quick setup and control VPN via PPTP/L2TP/OpenL2TP.

%prep
%setup -q -n %{name}-src-%{version}

%build
./compile.sh

%install
mkdir -p %{buildroot}%{_datadir}/%{name}
mkdir -p %{buildroot}%{_datadir}/%{name}/scripts
mkdir -p %{buildroot}%{_datadir}/%{name}/wiki
mkdir -p %{buildroot}%{_datadir}/%{name}/lang
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_datadir}/applications
mkdir -p %{buildroot}%{_datadir}/pixmaps
mkdir -p %{buildroot}/lib/libDrakX/network/connection

cp -f ./%{name}/%{name} %{buildroot}%{_bindir}
cp -f ./ponoff/ponoff %{buildroot}%{_bindir}
cp -f ./vpnmcc/vpnmcc %{buildroot}%{_bindir}
install -m 0644 ./ponoff.png %{buildroot}%{_datadir}/pixmaps/
install -m 0644 ./%{name}.png %{buildroot}%{_datadir}/pixmaps/
cp -f ./*.ico %{buildroot}%{_datadir}/%{name}
cp -f ./vpnlinux %{buildroot}%{_bindir}
cp -rf ./scripts %{buildroot}%{_datadir}/%{name}/
cp -rf ./wiki %{buildroot}%{_datadir}/%{name}/
cp -rf ./lang %{buildroot}%{_datadir}/%{name}/

install -dm 755 %{buildroot}%{_datadir}/applications
cat > ponoff.desktop << EOF
[Desktop Entry]
GenericName=Control VPN PPTP/L2TP/OpenL2TP
GenericName[ru]=Управление соединением VPN PPTP/L2TP/OpenL2TP
GenericName[uk]=Керування з'єднанням VPN PPTP/L2TP/OpenL2TP
Name=ponoff
Exec=ponoff
Comment=Control VPN via PPTP/L2TP/OpenL2TP
Comment[ru]=Управление соединением VPN через PPTP/L2TP/OpenL2TP
Comment[uk]=Керування з'єднанням VPN через PPTP/L2TP/OpenL2TP
Icon=ponoff
Type=Application
Categories=GTK;System;Monitor;X-MageiaLinux-CrossDesktop;
X-KDE-autostart-after=kdesktop
StartupNotify=false
EOF
install -m 0644 ponoff.desktop \
%{buildroot}%{_datadir}/applications/ponoff.desktop

cat > %{name}.desktop << EOF
[Desktop Entry]
GenericName=Setup VPN PPTP/L2TP/OpenL2TP
GenericName[ru]=Настройка соединения VPN PPTP/L2TP/OpenL2TP
GenericName[uk]=Налаштування з’єднання VPN PPTP/L2TP/OpenL2TP
Name=%{name}
Exec=%{name}
Comment=Setup VPN via PPTP/L2TP/OpenL2TP
Comment[ru]=Настройка соединения VPN через PPTP/L2TP/OpenL2TP
Comment[uk]=Налаштування з’єднання VPN через PPTP/L2TP/OpenL2TP
Icon=%{name}
Type=Application
Categories=GTK;System;Monitor;X-MageiaLinux-CrossDesktop;
StartupNotify=false
EOF
install -m 0644 %{name}.desktop \
%{buildroot}%{_datadir}/applications/%{name}.desktop

install -pm0644 -D %{SOURCE1} %{buildroot}/usr/lib/libDrakX/network/vpn/%{name}.pm
install -pm0644 -D %{SOURCE2} %{buildroot}/usr/lib/libDrakX/network/vpn/vpnmcc.pm

mkdir -p %{buildroot}%{_datadir}/polkit-1/actions
cp -f polkit/*.policy %{buildroot}%{_datadir}/polkit-1/actions/

%files
%{_bindir}/%{name}
%{_bindir}/ponoff
%{_bindir}/vpnlinux
%{_bindir}/vpnmcc
%{_datadir}/%{name}/lang
%{_datadir}/pixmaps/ponoff.png
%{_datadir}/pixmaps/%{name}.png
%{_datadir}/%{name}/*.ico
%{_datadir}/%{name}/scripts
%{_datadir}/%{name}/wiki
%{_datadir}/applications/ponoff.desktop
%{_datadir}/applications/%{name}.desktop
%{_prefix}/lib/libDrakX/network/vpn/%{name}.pm
%{_prefix}/lib/libDrakX/network/vpn/vpnmcc.pm
%{_datadir}/polkit-1/actions/*.policy
