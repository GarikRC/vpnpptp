%define rel 3
%define distsuffix edm

%{?dist: %{expand: %%define %dist 1}}

Summary: Tools for setup and control MS VPN via PPTP
Summary(ru): Инструмент для установки и управления соединением MS VPN через PPTP
Summary(uk): Інструмент для встановлення та керування з'єднанням MS VPN через PPTP
Name: vpnpptp-kde-one
Version: 0.1.3
Release: %mkrel %{rel}
License: GPL2
Group: Network

Packager: Alexander Kazancev <kazancas@mandriva.ru>; Alex Loginov <loginov_alex@inbox.ru>, <loginov.alex.valer@gmail.com>
Vendor: Mandriva Russia, http://www.mandriva.ru

Source: vpnpptp-src-%{version}.tar.gz
Source1: vpnpptp_kde_one.pm
%ifarch x86_64
Patch0: ponoff.patch
Patch1: mandriva_pptp.patch
Patch2: ponoff_project1.patch
Patch3: mandriva_pptp_project1.patch
%endif
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

BuildRequires: fpc-src = 2.4.0, fpc = 2.4.0, gdk-pixbuf, gtk+, glibc, gdb, lazarus, upx
%ifarch i586
BuildRequires: libglib1.2-devel, libgdk-pixbuf2-devel
%endif
%ifarch x86_64
BuildRequires: lib64glib1.2-devel, lib64gdk-pixbuf2-devel
%endif
Requires: pptp-linux
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
%ifarch x86_64
%patch0 -p0
%patch1 -p0
%patch2 -p0
%patch3 -p0
%endif

%postun
rm -f %{_datadir}/applications/ponoff.desktop.old
rm -f %{_datadir}/applications/vpnpptp.desktop.old

%post
ln -s /opt/vpnpptp/ponoff /usr/bin/ponoff
ln -s /opt/vpnpptp/vpnpptp /usr/bin/vpnpptp

%pre

%preun

%build
./compile.sh

%install
mkdir $RPM_BUILD_ROOT/opt
mkdir $RPM_BUILD_ROOT/opt/vpnpptp
mkdir $RPM_BUILD_ROOT/opt/vpnpptp/scripts
mkdir $RPM_BUILD_ROOT/opt/vpnpptp/wiki
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
cp -rf ./wiki $RPM_BUILD_ROOT/opt/vpnpptp/
cp -rf ./lang $RPM_BUILD_ROOT/opt/vpnpptp/

install -dm 755 %{buildroot}%{_datadir}/applications
cat > ponoff.desktop << EOF
[Desktop Entry]
Encoding=UTF-8
GenericName=VPN PPTP Control
GenericName[ru]=Управление соединением VPN PPTP
GenericName[uk]=Керування з'єднанням VPN PPTP
Name=ponoff
Name[ru]=ponoff
Name[uk]=ponoff
Exec=/opt/vpnpptp/ponoff
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
Name=vpnpptp
Name[ru]=vpnpptp
Name[uk]=vpnpptp
Exec=/opt/vpnpptp/vpnpptp
Comment=Setup MS VPN via PPTP
Comment[ru]=Настройка соединения VPN PPTP
Comment[uk]=Налаштування з’єднання VPN PPTP
Icon=/opt/vpnpptp/vpnpptp.png
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

/opt/vpnpptp/vpnpptp
/opt/vpnpptp/ponoff
/opt/vpnpptp/lang
/opt/vpnpptp/ponoff.png
/opt/vpnpptp/vpnpptp.png
/opt/vpnpptp/*.ico
/opt/vpnpptp/scripts
/opt/vpnpptp/wiki
%{_datadir}/applications/ponoff.desktop
%{_datadir}/applications/vpnpptp.desktop
/usr/lib/libDrakX/network/vpn/vpnpptp_kde_one.pm

%changelog
