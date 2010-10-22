cat > /tmp/vpnpptp-allde-edm/opt/vpnpptp/ponoff.desktop << EOF
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
Comment=Control MS VPN via PPTP/L2TP
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
chmod 0644 /tmp/vpnpptp-allde-edm/opt/vpnpptp/ponoff.desktop

cat > /tmp/vpnpptp-allde-edm/opt/vpnpptp/vpnpptp.desktop << EOF
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
chmod 0644 /tmp/vpnpptp-allde-edm/opt/vpnpptp/vpnpptp.desktop

cd /tmp/vpnpptp-allde-edm/src/modules
/usr/bin/fpc $(cat ./MyMessageBox.compiled | grep "Params Value" | cut -d\" -f2)
/usr/bin/strip -s ./mymessagebox

cd /tmp/vpnpptp-allde-edm/src/vpnpptp
/usr/bin/fpc $(cat ./project1.compiled | grep "Params Value" | cut -d\" -f2) -Fu../modules/
/usr/bin/strip -s ./vpnpptp

cd /tmp/vpnpptp-allde-edm/src/ponoff
/usr/bin/fpc $( cat ./project1.compiled | grep "Params Value" | cut -d\" -f2) -Fu../modules/
/usr/bin/strip -s ./ponoff

cp -f /tmp/vpnpptp-allde-edm/src/ponoff/ponoff /tmp/vpnpptp-allde-edm/opt/vpnpptp/ponoff
cp -f /tmp/vpnpptp-allde-edm/src/vpnpptp/vpnpptp /tmp/vpnpptp-allde-edm/opt/vpnpptp/vpnpptp
mkdir /tmp/vpnpptp-allde-edm/usr
mkdir /tmp/vpnpptp-allde-edm/usr/bin
cp -f /tmp/vpnpptp-allde-edm/src/vpnpptp/vpnpptp /tmp/vpnpptp-allde-edm/usr/bin
cp -f /tmp/vpnpptp-allde-edm/src/ponoff/ponoff /tmp/vpnpptp-allde-edm/usr/bin
mkdir /tmp/vpnpptp-allde-edm/usr/share
mkdir /tmp/vpnpptp-allde-edm/usr/share/pixmaps
cp -f /tmp/vpnpptp-allde-edm/opt/vpnpptp/vpnpptp.png /tmp/vpnpptp-allde-edm/usr/share/pixmaps
cp -f /tmp/vpnpptp-allde-edm/opt/vpnpptp/ponoff.png /tmp/vpnpptp-allde-edm/usr/share/pixmaps
mkdir /tmp/vpnpptp-allde-edm/usr/share/applications
cp -f /tmp/vpnpptp-allde-edm/opt/vpnpptp/vpnpptp.desktop /tmp/vpnpptp-allde-edm/usr/share/applications
cp -f /tmp/vpnpptp-allde-edm/opt/vpnpptp/ponoff.desktop /tmp/vpnpptp-allde-edm/usr/share/applications
rm -rf /tmp/vpnpptp-allde-edm/src
rm -f /tmp/vpnpptp-allde-edm/debcompile.sh
