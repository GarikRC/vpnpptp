%define rel 1

%{?dist: %{expand: %%define %dist 1}}

Summary: Tools for setup and control MS VPN via PPTP
Summary(uk): Інструмент для встановлення та керування з'єднанням MS VPN через PPT
Summary(ru): Инструмент для установки и управления соединением MS VPN через PPTP
Name: vpnpptp-allde
Version: 0.0.6
Release: %mkrel %{rel}
License: GPL2
Group: Network

Packager: Alexander Kazancev <kazancas@mandriva.ru>, Alex Loginov <loginov_alex@inbox.ru>
Vendor: Mandriva Russia, http://www.mandriva.ru

Source: vpnpptp-src-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

BuildRequires: fpc-src = 2.2.4, fpc = 2.2.4, gdk-pixbuf, gtk+, glibc, gdb, libglib1.2-devel, libgdk-pixbuf2-devel, lazarus, upx
Requires: gksu, pptp-linux
Obsoletes: vpnpptp-allde < 0.0.6
Obsoletes: vpnpptp-kde-one < 0.0.6

%description
Tools for easy and quick setup and control MS VPN via PPTP
%description -l ru
Инструмент для легкого и быстрого подключения и управления соединением MS VPN через PPTP
%description -l uk
Інструмент для легкого і швидкого підключення і керування з'єднанням MS VPN через PPTP

%prep

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT

%setup -n vpnpptp-src-%{version}

%postun

%post

%pre

%preun

%build
./compile.sh

%install
mkdir $RPM_BUILD_ROOT/opt
mkdir $RPM_BUILD_ROOT/opt/vpnpptp
mkdir $RPM_BUILD_ROOT/opt/vpnpptp/scripts
mkdir $RPM_BUILD_ROOT/opt/vpnpptp/lang
mkdir $RPM_BUILD_ROOT/usr
mkdir $RPM_BUILD_ROOT/usr/bin
mkdir $RPM_BUILD_ROOT/usr/share
mkdir $RPM_BUILD_ROOT/usr/share/applications
mkdir $RPM_BUILD_ROOT/usr/lib
mkdir $RPM_BUILD_ROOT/usr/lib/libDrakX
mkdir $RPM_BUILD_ROOT/usr/lib/libDrakX/network
mkdir $RPM_BUILD_ROOT/usr/lib/libDrakX/network/connection

cp -f ./mandriva_pptp/vpnpptp $RPM_BUILD_ROOT/opt/vpnpptp/
cp -f ./Pon_off/ponoff $RPM_BUILD_ROOT/opt/vpnpptp/
cp -f ./ponoff.png $RPM_BUILD_ROOT/opt/vpnpptp/
cp -f ./vpnpptp.png $RPM_BUILD_ROOT/opt/vpnpptp/
cp -f ./*.ico $RPM_BUILD_ROOT/opt/vpnpptp
cp -rf ./scripts $RPM_BUILD_ROOT/opt/vpnpptp/
cp -rf ./lang $RPM_BUILD_ROOT/opt/vpnpptp/

install -dm 755 %{buildroot}%{_datadir}/applications
cat > ponoff.desktop << EOF
[Desktop Entry]
Encoding=UTF-8
GenericName=VPN PPTP Control
GenericName[ru]=Управление соединением VPN PPTP
GenericName[uk]=Керування з'єднанням VPN PPTP
Name=Connect VPN PPT
Name[ru]=Подключение VPN PPTP
Name[uk]=З’єднання VPN PPTP
Exec=gksu -u root -l /opt/vpnpptp/ponoff
Comment=Control MS VPN via PPTP
Comment[ru]=Управление соединением MS VPN через PPTP
Comment[uk]=Керування з'єднанням MS VPN через PPTP
Icon=/opt/vpnpptp/ponoff.png
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
[Desktop Entry]
Encoding=UTF-8
GenericName=VPN PPTP Setup
GenericName[ru]=Настройка соединения VPN PPTP
GenericName[uk]=Налаштування з’єднання VPN PPTP
Name=Setup VPN PPTP
Name[ru]=Настройка VPN PPTP
Name[uk]=Налаштування VPN PPTP
Exec=gksu -u root -l /opt/vpnpptp/vpnpptp
Comment=Setup MS VPN via PPTP
Comment[ru]=Настройка соединения VPN PPTP
Comment[uk]=Налаштування з’єднання VPN PPTP
Icon=/opt/vpnpptp/vpnpptp.png
Type=Application
Categories=GTK;System;Network;Monitor;X-MandrivaLinux-CrossDesktop;
X-KDE-SubstituteUID=true
X-KDE-Username=root
StartupNotify=false
EOF
install -m 0644 vpnpptp.desktop \
%{buildroot}%{_datadir}/applications/vpnpptp.desktop

%clean

%files
%defattr(-,root, root)

/opt/vpnpptp/vpnpptp
/opt/vpnpptp/ponoff
/opt/vpnpptp/lang
/opt/vpnpptp/ponoff.png
/opt/vpnpptp/vpnpptp.png
/opt/vpnpptp/*.ico
/opt/vpnpptp/scripts
%{_datadir}/applications/ponoff.desktop
%{_datadir}/applications/vpnpptp.desktop

%changelog
* Mon Mar 22 2010 Alex Loginov <loginov_alex@inbox.ru> - 0.0.6
- New release

* Thu Dec 22 2009 ALexander Kazancev <kazancas@mandriva.ru> - 0.0.4.1
- Internationalisation version and dhcp route script

* Thu Dec 9 2009 Alexander Kazancev <kazancas@mandriva.ru> - 0.0.4
- New version

* Fri Nov 27 2009 Alexander Kazancev <kazancas@mandriva.ru> - 0.0.2
- New release

* Mon May 18 2009 Alexander Kazancev <kazancas@gmail.com> - 0.0.1
- Initial release