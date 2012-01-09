#!/bin/sh

#Передайте этому скрипту в качестве первого параметра архитектуру Lazarus'а i386, x86_64 и т.д.
#Передайте этому скрипту в качестве второго параметра параметр lib или lib64 в зависимости от архитектуры Lazarus'а
#Передайте этому скрипту в качестве третьего параметра номер версии собираемого пакета
#Передайте этому скрипту в качестве четвертого параметра архитектуру i386, amd64 и т.д.
#Выполните этот скрипт под root

FPC=/usr/bin/fpc
LAZARUS_ARCH=$1
LIBDIRPART=$2
NUM_VERSION=$3
ARCH=$4
LAZARUS_LIB=/usr/$LIBDIRPART/lazarus/*/lcl/units/$LAZARUS_ARCH-linux
LAZARUS_LIB_PKG=/usr/$LIBDIRPART/lazarus/*/packages/units/$LAZARUS_ARCH-linux
LAZARUS_LIB_COMP=/usr/$LIBDIRPART/lazarus/*/components/synedit/units/$LAZARUS_ARCH-linux
LAZARUS_LIB_IDEINTF=/usr/$LIBDIRPART/lazarus/*/ideintf/units/$LAZARUS_ARCH-linux

if [ -z "$(env | grep USER=root)" ];then
    echo "You're not the root!"
    exit 0
fi
	
if [ $# -ne 4 ];then
    echo "For this script you must write a 4 parameters"
    exit 0
fi
		
rm -rf ./build/
rm -rf ./vpnpptp-src-$NUM_VERSION/
		
mkdir -p ./build/usr/share/applications/
		
cat > ./build/usr/share/applications/ponoff.desktop << EOF
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
chmod 0644 ./build/usr/share/applications/ponoff.desktop
		
cat > ./build/usr/share/applications/vpnpptp.desktop << EOF
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
chmod 0644 ./build/usr/share/applications/vpnpptp.desktop
		
tar -xf vpnpptp-src-$NUM_VERSION.tar.gz
		
cd ./vpnpptp-src-$NUM_VERSION/modules/
		
$FPC -MObjFPC -C -Xs -Scgi -Os -O3 -XX -vewnhi -l -Fu$LAZARUS_LIB -Fu$LAZARUS_LIB/gtk2 -Fu$LAZARUS_LIB_PKG -Fu./modules/ -Fu. -omymessagebox -dLCL -dLCLgtk2 MyMessageBox.lpr
if [ ! -f ./mymessagebox ]
then
   echo "Compillation mymessagebox error!"
   cd ..
   cd ..
   rm -rf ./build/
   rm -rf ./vpnpptp-src-$NUM_VERSION/
   exit 0
#else
#   if [ -f `which upx` ] 
#   then
#     upx  -9 ./mymessagebox
#   fi  
fi
		                                        
		                                        
cd ..
cd ..
cd ./vpnpptp-src-$NUM_VERSION/vpnpptp/
		                                        
$FPC -MObjFPC -C -Xs -Scgi -Os -O3 -XX -vewnhi -l -Fu../modules -Fu$LAZARUS_LIB_COMP -Fu$LAZARUS_LIB_IDEINTF -Fu$LAZARUS_LIB -Fu$LAZARUS_LIB/gtk2 -Fu$LAZARUS_LIB_PKG -Fu./vpnpptp/ -Fu. -ovpnpptp -dLCL -dLCLgtk2 project1.pas
if [ ! -f ./vpnpptp ]
then
   echo "Compillation vpnpptp error!"
   cd ..
   cd ..
   rm -rf ./build/
   rm -rf ./vpnpptp-src-$NUM_VERSION/
   exit 0
#else
#if [ -f `which upx` ] 
#then
#  upx  -9 ./vpnpptp
#fi
fi
		                                                                                
		                                                                                
cd ..
cd ..
cd ./vpnpptp-src-$NUM_VERSION/ponoff/
		                                                                                
$FPC -MObjFPC -C -Xs -Scgi -Os -O3 -XX -vewnhi -l -Fu../modules -Fu$LAZARUS_LIB -Fu$LAZARUS_LIB/gtk2 -Fu$LAZARUS_LIB_PKG -Fu./ponoff/ -Fu. -oponoff -dLCL -dLCLgtk2 project1.pas
if [ ! -f ./ponoff ]
then
   echo "Compillation ponoff error!"
   cd ..
   cd ..
   rm -rf ./build/
   rm -rf ./vpnpptp-src-$NUM_VERSION/
   exit 0
#else
#if [ -f `which upx` ] 
#then
#   upx  -9 ./ponoff
#fi
fi
		                                                                                                                        
		                                                                                                                        
cd ..
cd ..
		                                                                                                                        
mkdir -p ./build/usr/bin
		                                                                                                                        
cp -f ./vpnpptp-src-$NUM_VERSION/ponoff/ponoff ./build/usr/bin/ponoff
cp -f ./vpnpptp-src-$NUM_VERSION/vpnpptp/vpnpptp ./build/usr/bin/vpnpptp
cp -f ./vpnpptp-src-$NUM_VERSION/vpnlinux ./build/usr/bin/vpnpptp
		                                                                                                                        
mkdir -p ./build/usr/share/pixmaps
		                                                                                                                        
cp -f ./vpnpptp-src-$NUM_VERSION/vpnpptp.png ./build/usr/share/pixmaps
cp -f ./vpnpptp-src-$NUM_VERSION/ponoff.png ./build/usr/share/pixmaps
		                                                                                                                        
mkdir -p ./build/usr/share/vpnpptp/
		                                                                                                                        
cp -rf ./vpnpptp-src-$NUM_VERSION/scripts ./build/usr/share/vpnpptp/
cp -rf ./vpnpptp-src-$NUM_VERSION/wiki ./build/usr/share/vpnpptp/
cp -rf ./vpnpptp-src-$NUM_VERSION/lang ./build/usr/share/vpnpptp/
cp -f ./vpnpptp-src-$NUM_VERSION/on.ico ./build/usr/share/vpnpptp/
cp -f ./vpnpptp-src-$NUM_VERSION/off.ico ./build/usr/share/vpnpptp/
		                                                                                                                        
mkdir -p ./build/DEBIAN/
		                                                                                                                        
cp -f ./vpnpptp-src-$NUM_VERSION/DEBIAN/ubuntu/control ./build/DEBIAN/
echo "Architecture: $ARCH" >> ./build/DEBIAN/control
echo "" >> ./build/DEBIAN/control
chmod 0755 ./build/DEBIAN/control 
		                                                                                                                        
dpkg -b ./build/ vpnpptp-allde-$NUM_VERSION-$ARCH.deb
		                                                                                                                        
rm -rf ./build/
rm -rf ./vpnpptp-src-$NUM_VERSION/
		                                                                                                                        