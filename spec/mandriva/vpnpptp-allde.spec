%define rel 2

Summary: Tools for setup and control VPN via PPTP/L2TP/OpenL2TP
Name: vpnpptp-allde
Version: 0.3.4
Release: %mkrel %{rel}
License: GPL2
Group: System/Configuration/Networking
Url: http://code.google.com/p/vpnpptp

Source0: vpnpptp-src-%{version}.tar.gz
Source1: vpnpptp.pm
Source2: vpnmandriva.pm
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

BuildRequires: fpc-src >= 2.4.4, fpc >= 2.4.4, lazarus >= 0.9.30
#раскомментировать при сборке в репозиторий
#Requires: gksu, pptp-linux, xl2tpd >= 1.2.7, openl2tp

%description
Tools for easy and quick setup and control VPN via PPTP/L2TP/OpenL2TP

%prep

%setup -q -n vpnpptp-src-%{version}

%build
%ifarch x86_64
./mandriva.compile.sh x86_64 lib64
%else
./mandriva.compile.sh i386 lib
%endif

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{_datadir}/vpnpptp
mkdir -p %{buildroot}%{_datadir}/vpnpptp/scripts
mkdir -p %{buildroot}%{_datadir}/vpnpptp/wiki
mkdir -p %{buildroot}%{_datadir}/vpnpptp/lang
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_datadir}/applications
mkdir -p %{buildroot}%{_datadir}/pixmaps
mkdir -p %{buildroot}%/lib/libDrakX/network/connection

cp -f ./vpnpptp/vpnpptp %{buildroot}%{_bindir}
cp -f ./ponoff/ponoff %{buildroot}%{_bindir}
cp -f ./vpnmandriva/vpnmandriva %{buildroot}%{_bindir}
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
#!/usr/bin/env xdg-open

[Desktop Entry]
Encoding=UTF-8
GenericName=VPN PPTP/L2TP/OpenL2TP Control
GenericName[ru]=Управление соединением VPN PPTP/L2TP/OpenL2TP
GenericName[uk]=Керування з'єднанням VPN PPTP/L2TP/OpenL2TP
Name=ponoff
Name[ru]=ponoff
Name[uk]=ponoff
Exec=/usr/bin/ponoff
Comment=Control VPN via PPTP/L2TP/OpenL2TP
Comment[ru]=Управление соединением VPN через PPTP/L2TP/OpenL2TP
Comment[uk]=Керування з'єднанням VPN через PPTP/L2TP/OpenL2TP
Icon=/usr/share/pixmaps/ponoff.png
Type=Application
Categories=GTK;System;Network;Monitor;X-MandrivaLinux-CrossDesktop;
X-KDE-SubstituteUID=true
X-KDE-Username=root
X-KDE-autostart-after=kdesktop
StartupNotify=false
EOF
install -m 0644 ponoff.desktop \
%{buildroot}%{_datadir}/applications/ponoff.desktop

install -dm 755 %{buildroot}%{_datadir}/applications
cat > vpnpptp.desktop << EOF
#!/usr/bin/env xdg-open

[Desktop Entry]
Encoding=UTF-8
GenericName=VPN PPTP/L2TP/OpenL2TP Setup
GenericName[ru]=Настройка соединения VPN PPTP/L2TP/OpenL2TP
GenericName[uk]=Налаштування з’єднання VPN PPTP/L2TP/OpenL2TP
Name=vpnpptp
Name[ru]=vpnpptp
Name[uk]=vpnpptp
Exec=/usr/bin/vpnpptp
Comment=Setup VPN via PPTP/L2TP/OpenL2TP
Comment[ru]=Настройка соединения VPN PPTP/L2TP/OpenL2TP
Comment[uk]=Налаштування з’єднання VPN PPTP/L2TP/OpenL2TP
Icon=/usr/share/pixmaps/vpnpptp.png
Type=Application
Categories=GTK;System;Network;Monitor;X-MandrivaLinux-CrossDesktop;
X-KDE-SubstituteUID=true
X-KDE-Username=root
StartupNotify=false
EOF
install -m 0644 vpnpptp.desktop \
%{buildroot}%{_datadir}/applications/vpnpptp.desktop

install -pm0644 -D %SOURCE1 %{buildroot}/usr/lib/libDrakX/network/vpn/vpnpptp.pm
install -pm0644 -D %SOURCE2 %{buildroot}/usr/lib/libDrakX/network/vpn/vpnmandriva.pm

%clean
rm -rf %{buildroot}

%files
%defattr(-,root, root)

%{_bindir}/vpnpptp
%{_bindir}/ponoff
%{_bindir}/vpnlinux
%{_bindir}/vpnmandriva
%{_datadir}/vpnpptp/lang
%{_datadir}/pixmaps/ponoff.png
%{_datadir}/pixmaps/vpnpptp.png
%{_datadir}/vpnpptp/*.ico
%{_datadir}/vpnpptp/scripts
%{_datadir}/vpnpptp/wiki
%{_datadir}/applications/ponoff.desktop
%{_datadir}/applications/vpnpptp.desktop
/usr/lib/libDrakX/network/vpn/vpnpptp.pm
/usr/lib/libDrakX/network/vpn/vpnmandriva.pm

%changelog
