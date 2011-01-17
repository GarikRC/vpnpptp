%define rel 5

%{?dist: %{expand: %%define %dist 1}}

Summary: Tools for setup and control VPN via PPTP/L2TP
#Summary(ru): Инструмент для установки и управления соединением VPN через PPTP/L2TP
#Summary(uk): Інструмент для встановлення та керування з'єднанням VPN через PPTP/L2TP
Name: vpnpptp-kde-one
Version: 0.2.9
Release: %mkrel %{rel}
License: GPL2
Group: Network

Packager: Alex Loginov <loginov_alex@inbox.ru>, <loginov.alex.valer@gmail.com>
Vendor: Mandriva Russia, http://www.mandriva.ru

Source0: vpnpptp-src-%{version}.tar.gz
Source1: vpnpptp_kde_one.pm
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

BuildRequires: fpc-src >= 2.2.4, fpc >= 2.2.4, lazarus
Requires: pptp-linux, xl2tpd
Obsoletes: vpnpptp-allde < 0.0.6
Obsoletes: vpnpptp-kde-one < 0.0.6

%description
Tools for easy and quick setup and control VPN via PPTP/L2TP
%description -l ru
Инструмент для легкого и быстрого подключения и управления соединением VPN через PPTP/L2TP
%description -l uk
Інструмент для легкого і швидкого підключення і керування з'єднанням VPN через PPTP/L2TP

%prep

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT

%setup -n vpnpptp-src-%{version}


%postun

%post

%pre
#удалить ссылки если есть
rm -f /usr/bin/vpnpptp 
rm -f /usr/bin/ponoff
#обеспечить переход с allde на kde-one или наоборот
rm -f %{_datadir}/pixmaps/ponoff.png
rm -f %{_datadir}/pixmaps/vpnpptp.png
if [ -a %{_datadir}/applications/ponoff.desktop.old ]
then
	rm -f %{_datadir}/applications/ponoff.desktop.old
fi
if [ -a %{_datadir}/applications/vpnpptp.desktop.old ]
then
	rm -f %{_datadir}/applications/vpnpptp.desktop.old
fi

%preun

%build
./mandriva.compile.sh

%install
mkdir $RPM_BUILD_ROOT/usr
mkdir $RPM_BUILD_ROOT/usr/share
mkdir $RPM_BUILD_ROOT/usr/share/vpnpptp
mkdir $RPM_BUILD_ROOT/usr/share/vpnpptp/scripts
mkdir $RPM_BUILD_ROOT/usr/share/vpnpptp/wiki
mkdir $RPM_BUILD_ROOT/usr/share/vpnpptp/lang
mkdir $RPM_BUILD_ROOT/usr/bin
mkdir $RPM_BUILD_ROOT/usr/share/applications
mkdir $RPM_BUILD_ROOT/usr/share/pixmaps
mkdir $RPM_BUILD_ROOT/usr/lib
mkdir $RPM_BUILD_ROOT/usr/lib/libDrakX
mkdir $RPM_BUILD_ROOT/usr/lib/libDrakX/network
mkdir $RPM_BUILD_ROOT/usr/lib/libDrakX/network/connection

cp -f ./vpnpptp/vpnpptp $RPM_BUILD_ROOT/usr/bin/
cp -f ./ponoff/ponoff $RPM_BUILD_ROOT/usr/bin/
cp -f ./ponoff.png $RPM_BUILD_ROOT/usr/share/pixmaps/
cp -f ./vpnpptp.png $RPM_BUILD_ROOT/usr/share/pixmaps/
chmod 0644 $RPM_BUILD_ROOT/usr/share/pixmaps/ponoff.png
chmod 0644 $RPM_BUILD_ROOT/usr/share/pixmaps/vpnpptp.png
cp -f ./*.ico $RPM_BUILD_ROOT/usr/share/vpnpptp
cp -f ./*.png $RPM_BUILD_ROOT/usr/share/vpnpptp
cp -rf ./scripts $RPM_BUILD_ROOT/usr/share/vpnpptp/
cp -rf ./wiki $RPM_BUILD_ROOT/usr/share/vpnpptp/
cp -rf ./lang $RPM_BUILD_ROOT/usr/share/vpnpptp/

install -dm 755 %{buildroot}%{_datadir}/applications
cat > ponoff.desktop << EOF
#!/usr/bin/env xdg-open

[Desktop Entry]
Encoding=UTF-8
GenericName=VPN PPTP/L2TP Control
GenericName[ru]=Управление соединением VPN PPTP/L2TP
GenericName[uk]=Керування з'єднанням VPN PPTP/L2TP
Name=ponoff
Name[ru]=ponoff
Name[uk]=ponoff
Exec=/usr/bin/ponoff
Comment=Control VPN via PPTP/L2TP
Comment[ru]=Управление соединением VPN через PPTP/L2TP
Comment[uk]=Керування з'єднанням VPN через PPTP/L2TP
Icon=/usr/share/pixmaps/ponoff.png
Type=Application
Categories=GTK;System;Network;Monitor;X-MandrivaLinux-CrossDesktop;
X-KDE-SubstituteUID=true
X-KDE-Username=root
StartupNotify=false
EOF
install -m 0644 ponoff.desktop \
%{buildroot}%{_datadir}/applications/ponoff.desktop

install -dm 755 %{buildroot}%{_datadir}/applications
cat > vpnpptp.desktop << EOF
#!/usr/bin/env xdg-open

[Desktop Entry]
Encoding=UTF-8
GenericName=VPN PPTP/L2TP Setup
GenericName[ru]=Настройка соединения VPN PPTP/L2TP
GenericName[uk]=Налаштування з’єднання VPN PPTP/L2TP
Name=vpnpptp
Name[ru]=vpnpptp
Name[uk]=vpnpptp
Exec=/usr/bin/vpnpptp
Comment=Setup VPN via PPTP/L2TP
Comment[ru]=Настройка соединения VPN PPTP/L2TP
Comment[uk]=Налаштування з’єднання VPN PPTP/L2TP
Icon=/usr/share/pixmaps/vpnpptp.png
Type=Application
Categories=GTK;System;Network;Monitor;X-MandrivaLinux-CrossDesktop;
X-KDE-SubstituteUID=true
X-KDE-Username=root
X-KDE-autostart-after=kdesktop
StartupNotify=false
EOF
install -m 0644 vpnpptp.desktop \
%{buildroot}%{_datadir}/applications/vpnpptp.desktop

install -pm0644 -D %SOURCE1 %{buildroot}/usr/lib/libDrakX/network/vpn/vpnpptp_kde_one.pm

%clean

%files
%defattr(-,root, root)

/usr/bin/vpnpptp
/usr/bin/ponoff
/usr/share/vpnpptp/lang
/usr/share/pixmaps/ponoff.png
/usr/share/pixmaps/vpnpptp.png
/usr/share/vpnpptp/*.ico
/usr/share/vpnpptp/*.png
/usr/share/vpnpptp/scripts
/usr/share/vpnpptp/wiki
%{_datadir}/applications/ponoff.desktop
%{_datadir}/applications/vpnpptp.desktop
/usr/lib/libDrakX/network/vpn/vpnpptp_kde_one.pm

%changelog
