%define rel 1

%{?dist: %{expand: %%define %dist 1}}

Summary: Tools for setup and control MS VPN via PPTP
Summary:ru Инструмент для установки и управления соединением MS VPN через PPTP
Name: vpnpptp
Version: 0.0.2
Release: %mkrel %{rel}
License: GPL2
Group: Network

Packager: Alexander Kazancev <kazancas@mandriva.ru>
Vendor: Mandriva Russia, http://www.mandriva.ru

Source: vpnpptp-src-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

BuildRequires: fpc-src = 2.2.4, fpc = 2.2.4, gdk-pixbuf, gtk+, glibc, gdb, libglib1.2-devel, libgdk-pixbuf2-devel, lazarus, upx

%description
Tools for easy and quick setup and control MS VPN via PPTP
%description -l ru
Инструмент для легкого и быстрого подключения и управления соединением MS VPN через PPTP

%prep
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT

%setup -n vpnpptp-src-%{version}

%postun
rm -rf /opt/vpnpptp
# убрал следующую строку
#rm -f /usr/bin/ponoff


%post
#убрал три строки
#printf "#Option for up connetion on VPN PPTP  \n" >> /etc/sudoers
#printf "ALL ALL=NOPASSWD:/opt/vpnpptp/vpnpptp  \n" >> /etc/sudoers
#ln -s /opt/vpnpptp/ponoff /usr/bin/ponoff

%build
./compile.sh

%install
rm -rf /opt/vpnpptp
mkdir $RPM_BUILD_ROOT/opt
mkdir $RPM_BUILD_ROOT/opt/vpnpptp
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
cp -f ./success $RPM_BUILD_ROOT/opt/vpnpptp/
cp -f ./ponoff.png $RPM_BUILD_ROOT/opt/vpnpptp/
cp -f ./vpnpptp.png $RPM_BUILD_ROOT/opt/vpnpptp/

install -dm 755 %{buildroot}%{_datadir}/applications
cat > ponoff.desktop << EOF
[Desktop Entry]
Encoding=UTF-8
GenericName=VPN PPTP Control
GenericName[ru]=Управление соединением VPN PPTP
Name=Connect VPN PPT
Name[ru]=Подключение VPN PPTP
#Exec=/usr/bin/ponoff - было
стало:
Exec=/opt/vpnpptp/ponoff
Comment=Control MS VPN via PPTP
Icon=/opt/vpnpptp/ponoff.png
Type=Application
Categories=GTK;System;Internet;Monitor;X-MandrivaLinux-CrossDesktop;
#следующие 2 строки добавлены
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
Name=Setup VPN PPTP
Name[ru]=Настройка VPN PPTP
#следующая строка изменена
Exec=/opt/vpnpptp/vpnpptp
Comment=Setup MS VPN via PPTP
Icon=/opt/vpnpptp/vpnpptp.png
Type=Application
Categories=GTK;System;Internet;Monitor;X-MandrivaLinux-CrossDesktop;
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
/opt/vpnpptp/success
/opt/vpnpptp/ponoff.png
/opt/vpnpptp/vpnpptp.png
%{_datadir}/applications/ponoff.desktop
%{_datadir}/applications/vpnpptp.desktop


%changelog
* Fri Nov 27 2009 Alexander Kazancev <kazancas@mandriva.ru> - 0.0.2
- New release

* Mon May 18 2009 Alexander Kazancev <kazancas@gmail.com> - 0.0.1
- Initial release