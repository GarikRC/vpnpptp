#!/bin/sh

cd ./opt/vpnpptp

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
Exec=gksu -u root -l /opt/vpnpptp/ponoff
Comment=Control VPN via PPTP/L2TP
Comment[ru]=Управление соединением VPN через PPTP/L2TP
Comment[uk]=Керування з'єднанням VPN через PPTP/L2TP
Icon=/opt/vpnpptp/ponoff.png
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
Exec=gksu -u root -l /opt/vpnpptp/vpnpptp
Comment=Setup VPN via PPTP/L2TP
Comment[ru]=Настройка соединения VPN PPTP/L2TP
Comment[uk]=Налаштування з’єднання VPN PPTP/L2TP
Icon=/opt/vpnpptp/vpnpptp.png
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

cp -f ./src/ponoff/ponoff ./opt/vpnpptp/ponoff
cp -f ./src/vpnpptp/vpnpptp ./opt/vpnpptp/vpnpptp
mkdir ./usr
mkdir ./usr/bin
mkdir ./usr/share
mkdir ./usr/share/pixmaps
mkdir ./usr/share/applications
cp -f ./opt/vpnpptp/vpnpptp.desktop ./usr/share/applications
cp -f ./opt/vpnpptp/ponoff.desktop ./usr/share/applications
rm -f ./opt/vpnpptp/vpnpptp.desktop
rm -f ./opt/vpnpptp/ponoff.desktop
rm -rf ./src
rm -f ./debcompile.sh
