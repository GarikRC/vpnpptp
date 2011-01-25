#!/bin/sh

# Передайте этому скрипту 2 параметра: номер версии собираемого пакета и архитектуру (i386, amd64 и т.д.)
# выполните этот скрипт под root

if [ -z "$(env | grep USER=root)" ];then
	echo "You're not the root!"
	exit 0
fi

if [ $# -ne 2 ];then
	echo "For this script you must write a two parameters"
	exit 0
fi

mkdir -p ./build/usr/share/applications/

cat > ./build/usr/share/applications/ponoff.desktop << EOF
#!/usr/bin/env xdg-open

[Desktop Entry]
Encoding=UTF-8
GenericName=VPN PPTP/L2TP Control
GenericName[ru]=Управление соединением VPN PPTP/L2TP
GenericName[uk]=Керування з'єднанням VPN PPTP/L2TP
Name=ponoff
Name[ru]=ponoff
Name[uk]=ponoff
Exec=gksu /usr/bin/ponoff
Comment=Control VPN via PPTP/L2TP
Comment[ru]=Управление соединением VPN через PPTP/L2TP
Comment[uk]=Керування з'єднанням VPN через PPTP/L2TP
Icon=/usr/share/pixmaps/ponoff.png
Type=Application
Categories=GTK;System;Network;Monitor;X-MandrivaLinux-CrossDesktop;
X-KDE-SubstituteUID=true
X-KDE-Username=root
X-KDE-autostart-after=kdesktop
StartupNotify=false
EOF
chmod 0644 ./build/usr/share/applications/ponoff.desktop

cat > ./build/usr/share/applications/vpnpptp.desktop << EOF
#!/usr/bin/env xdg-open

[Desktop Entry]
Encoding=UTF-8
GenericName=VPN PPTP/L2TP Setup
GenericName[ru]=Настройка соединения VPN PPTP/L2TP
GenericName[uk]=Налаштування з’єднання VPN PPTP/L2TP
Name=vpnpptp
Name[ru]=vpnpptp
Name[uk]=vpnpptp
Exec=gksu /usr/bin/vpnpptp
Comment=Setup VPN via PPTP/L2TP
Comment[ru]=Настройка соединения VPN PPTP/L2TP
Comment[uk]=Налаштування з’єднання VPN PPTP/L2TP
Icon=/usr/share/pixmaps/vpnpptp.png
Type=Application
Categories=GTK;System;Network;Monitor;X-MandrivaLinux-CrossDesktop;
X-KDE-SubstituteUID=true
X-KDE-Username=root
StartupNotify=false
EOF
chmod 0644 ./build/usr/share/applications/vpnpptp.desktop

tar -xf vpnpptp-src-$1.tar.gz

cd ./vpnpptp-src-$1/modules/

/usr/bin/fpc $(cat ./MyMessageBox.compiled | grep "Params Value" | cut -d\" -f2)
if [ ! -f ./mymessagebox ]
then
     echo "Compillation mymessagebox error!"
     cd ..
     cd ..
     rm -rf ./build/
     rm -rf ./vpnpptp-src-$1/
     exit 0
fi
/usr/bin/strip -s ./mymessagebox

cd ..
cd ..
cd ./vpnpptp-src-$1/vpnpptp/

/usr/bin/fpc $(cat ./project1.compiled | grep "Params Value" | cut -d\" -f2) -Fu../modules/
if [ ! -f ./vpnpptp ]
then
     echo "Compillation vpnpptp error!"
     cd ..
     cd ..
     rm -rf ./build/
     rm -rf ./vpnpptp-src-$1/
     exit 0
fi
/usr/bin/strip -s ./vpnpptp

cd ..
cd ..
cd ./vpnpptp-src-$1/ponoff/

/usr/bin/fpc $(cat ./project1.compiled | grep "Params Value" | cut -d\" -f2) -Fu../modules/
if [ ! -f ./ponoff ]
then
     echo "Compillation ponoff error!"
     cd ..
     cd ..
     rm -rf ./build/
     rm -rf ./vpnpptp-src-$1/
     exit 0
fi
/usr/bin/strip -s ./ponoff

cd ..
cd ..

mkdir -p ./build/usr/bin

cp -f ./vpnpptp-src-$1/ponoff/ponoff ./build/usr/bin/ponoff
cp -f ./vpnpptp-src-$1/vpnpptp/vpnpptp ./build/usr/bin/vpnpptp

mkdir -p ./build/usr/share/pixmaps

cp -f ./vpnpptp-src-$1/vpnpptp.png ./build/usr/share/pixmaps
cp -f ./vpnpptp-src-$1/ponoff.png ./build/usr/share/pixmaps

mkdir -p ./build/usr/share/vpnpptp/

cp -rf ./vpnpptp-src-$1/scripts ./build/usr/share/vpnpptp/
cp -rf ./vpnpptp-src-$1/wiki ./build/usr/share/vpnpptp/
cp -rf ./vpnpptp-src-$1/lang ./build/usr/share/vpnpptp/
cp -f ./vpnpptp-src-$1/vpnpptp.png ./build/usr/share/vpnpptp/
cp -f ./vpnpptp-src-$1/ponoff.png ./build/usr/share/vpnpptp/
cp -f ./vpnpptp-src-$1/on.ico ./build/usr/share/vpnpptp/
cp -f ./vpnpptp-src-$1/off.ico ./build/usr/share/vpnpptp/

mkdir -p ./build/DEBIAN/

cp -f ./vpnpptp-src-$1/DEBIAN/ubuntu/preinst ./build/DEBIAN/
chmod 0775 ./build/DEBIAN/preinst
cp -f ./vpnpptp-src-$1/DEBIAN/ubuntu/control ./build/DEBIAN/
chmod 0775 ./build/DEBIAN/control

dpkg -b ./build/ vpnpptp-allde-$1_$2.deb

rm -rf ./build/
rm -rf ./vpnpptp-src-$1/
