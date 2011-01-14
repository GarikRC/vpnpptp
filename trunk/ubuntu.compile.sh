#!/bin/sh

cd ./usr/share/vpnpptp

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
chmod 0644 ponoff.desktop

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
chmod 0644 vpnpptp.desktop

cd ..
cd ..

cd ./src/modules
/usr/bin/fpc $(cat ./MyMessageBox.compiled | grep "Params Value" | cut -d\" -f2)
/usr/bin/strip -s ./mymessagebox

cd ..
cd ..

cd ./src/vpnpptp
/usr/bin/fpc $(cat ./project1.compiled | grep "Params Value" | cut -d\" -f2) -Fu../modules/
/usr/bin/strip -s ./vpnpptp

cd ..
cd ..

cd ./src/ponoff
/usr/bin/fpc $( cat ./project1.compiled | grep "Params Value" | cut -d\" -f2) -Fu../modules/
/usr/bin/strip -s ./ponoff

cd ..
cd ..

mkdir ./usr/bin
cp -f ./src/ponoff/ponoff ./usr/bin/ponoff
cp -f ./src/vpnpptp/vpnpptp ./usr/bin/vpnpptp
mkdir ./usr/share/applications
mkdir ./usr/share/pixmaps
cp -f ./usr/share/vpnpptp/vpnpptp.png ./usr/share/pixmaps
cp -f ./usr/share/vpnpptp/ponoff.png ./usr/share/pixmaps
cp -f ./usr/share/vpnpptp/vpnpptp.desktop ./usr/share/applications
cp -f ./usr/share/vpnpptp/ponoff.desktop ./usr/share/applications
rm -f ./usr/share/vpnpptp/vpnpptp.desktop
rm -f ./usr/share/vpnpptp/ponoff.desktop
rm -rf ./src
rm -f ./ubuntu.compile.sh
