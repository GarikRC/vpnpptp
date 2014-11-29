#!/bin/bash

SOURCE=`dir -1|grep tar.gz`
echo SOURCE: $SOURCE

NUM_VERSION=`echo $SOURCE|sed 's/vpnpptp-src-//g'|sed 's/.tar.gz//g'`
echo NUM_VERSION: $NUM_VERSION

ARCH0=`uname -m`
echo ARCH0: $ARCH0

if [ "$ARCH0" = "x86_64" ] || [ "$ARCH0" = "amd64" ]
then
  ARCH=amd64
else
  ARCH=i386
fi
echo ARCH: $ARCH

rm -rf ./build/
rm -rf ./vpnpptp-src-$NUM_VERSION/

mkdir -p ./build/usr/share/applications/

cat > ./build/usr/share/applications/ponoff.desktop << EOF
#!/usr/bin/env xdg-open

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
chmod 0644 ./build/usr/share/applications/ponoff.desktop

cat > ./build/usr/share/applications/vpnpptp.desktop << EOF
[Desktop Entry]
GenericName=Setup VPN PPTP/L2TP/OpenL2TP
GenericName[ru]=Настройка соединения VPN PPTP/L2TP/OpenL2TP
GenericName[uk]=Налаштування з’єднання VPN PPTP/L2TP/OpenL2TP
Name=vpnpptp
Exec=vpnpptp
Comment=Setup VPN via PPTP/L2TP/OpenL2TP
Comment[ru]=Настройка соединения VPN через PPTP/L2TP/OpenL2TP
Comment[uk]=Налаштування з’єднання VPN через PPTP/L2TP/OpenL2TP
Icon=vpnpptp
Type=Application
Categories=GTK;System;Monitor;X-MageiaLinux-CrossDesktop;
StartupNotify=false
EOF
chmod 0644 ./build/usr/share/applications/vpnpptp.desktop

tar -xf vpnpptp-src-$NUM_VERSION.tar.gz

cd ./vpnpptp-src-$NUM_VERSION

./compile.sh

if [ ! -f ./modules/MyMessageBox ]
then
   echo "Compillation MyMessageBox error!"
   exit 0
fi
if [ ! -f ./vpnpptp/vpnpptp ]
then
   echo "Compillation vpnpptp error!"
   exit 0
fi
if [ ! -f ./ponoff/ponoff  ]
then
   echo "Compillation ponoff error!"
   exit 0
fi
if [ ! -f ./vpnmcc/vpnmcc ]
then
   echo "Compillation vpnmcc error!"
   exit 0
fi

cd ..

mkdir -p ./build/usr/bin

cp -f ./vpnpptp-src-$NUM_VERSION/ponoff/ponoff ./build/usr/bin/ponoff
cp -f ./vpnpptp-src-$NUM_VERSION/vpnpptp/vpnpptp ./build/usr/bin/vpnpptp
cp -f ./vpnpptp-src-$NUM_VERSION/vpnmcc/vpnmcc ./build/usr/bin/vpnmcc
cp -f ./vpnpptp-src-$NUM_VERSION/vpnlinux ./build/usr/bin/vpnlinux

mkdir -p ./build/usr/share/pixmaps

cp -f ./vpnpptp-src-$NUM_VERSION/vpnpptp.png ./build/usr/share/pixmaps
cp -f ./vpnpptp-src-$NUM_VERSION/ponoff.png ./build/usr/share/pixmaps

mkdir -p ./build/usr/share/vpnpptp/

cp -rf ./vpnpptp-src-$NUM_VERSION/scripts ./build/usr/share/vpnpptp/
cp -rf ./vpnpptp-src-$NUM_VERSION/wiki ./build/usr/share/vpnpptp/
cp -rf ./vpnpptp-src-$NUM_VERSION/lang ./build/usr/share/vpnpptp/
cp -f ./vpnpptp-src-$NUM_VERSION/on.ico ./build/usr/share/vpnpptp/
cp -f ./vpnpptp-src-$NUM_VERSION/off.ico ./build/usr/share/vpnpptp/

mkdir -p ./build/usr/share/polkit-1/actions

cp -f ./vpnpptp-src-$NUM_VERSION/polkit/* ./build/usr/share/polkit-1/actions/

mkdir -p ./build/DEBIAN/

cp -f ./vpnpptp-src-$NUM_VERSION/DEBIAN/debian/control ./build/DEBIAN/
echo "Architecture: $ARCH" >> ./build/DEBIAN/control
echo "" >> ./build/DEBIAN/control
chmod 0755 ./build/DEBIAN/control 

dpkg -b ./build/ vpnpptp-$NUM_VERSION-$ARCH.deb

rm -rf ./build/
rm -rf ./vpnpptp-src-$NUM_VERSION/

alien --to-rpm ./vpnpptp-$NUM_VERSION-$ARCH.deb --bump=0
