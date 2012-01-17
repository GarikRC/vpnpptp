#!/bin/sh

#Передайте этому скрипту в качестве первого параметра архитектуру Lazarus'а i386, x86_64 и т.д.
#Передайте этому скрипту в качестве второго параметра параметр lib или lib64 в зависимости от архитектуры Lazarus'а

FPC=/usr/bin/fpc
LAZARUS_ARCH=$1
LIBDIRPART=$2
LAZARUS_LIB=/usr/$LIBDIRPART/lazarus/lcl/units/$LAZARUS_ARCH-linux
LAZARUS_LIB_PKG=/usr/$LIBDIRPART/lazarus/packages/units/$LAZARUS_ARCH-linux
LAZARUS_LIB_COMP=/usr/$LIBDIRPART/lazarus/components/synedit/units/$LAZARUS_ARCH-linux
LAZARUS_LIB_IDEINTF=/usr/$LIBDIRPART/lazarus/ideintf/units/$LAZARUS_ARCH-linux

cd ./modules

$FPC -MObjFPC -C -Xs -Scgi -Os -O3 -XX -vewnhi -l -Fu$LAZARUS_LIB -Fu$LAZARUS_LIB/gtk2 -Fu$LAZARUS_LIB_PKG -Fu./modules/ -Fu. -omymessagebox -dLCL -dLCLgtk2 MyMessageBox.lpr
echo $LAZARUS_ARCH
if [ -f `which upx` ] 
then
  upx -9 ./mymessagebox
fi
  
cd ..
cd ./vpnpptp
  
$FPC -MObjFPC -C -Xs -Scgi -Os -O3 -XX -vewnhi -l -Fu../modules -Fu$LAZARUS_LIB_COMP -Fu$LAZARUS_LIB_IDEINTF -Fu$LAZARUS_LIB -Fu$LAZARUS_LIB/gtk2 -Fu$LAZARUS_LIB_PKG -Fu./vpnpptp/ -Fu. -ovpnpptp -dLCL -dLCLgtk2 project1.pas
if [ -f `which upx` ] 
then
  upx -9 ./vpnpptp
fi
    
cd ..
cd ./ponoff
    
$FPC -MObjFPC -C -Xs -Scgi -Os -O3 -XX -vewnhi -l -Fu../modules -Fu$LAZARUS_LIB -Fu$LAZARUS_LIB/gtk2 -Fu$LAZARUS_LIB_PKG -Fu./ponoff/ -Fu. -oponoff -dLCL -dLCLgtk2 project1.pas
if [ -f `which upx` ] 
then
  upx -9 ./ponoff
fi
      
cd ..
cd ./vpnmandriva
      
$FPC -MObjFPC -C -Xs -Scgi -Os -O3 -XX -vewnhi -l -Fu../modules -Fu$LAZARUS_LIB_COMP -Fu$LAZARUS_LIB_IDEINTF -Fu$LAZARUS_LIB -Fu$LAZARUS_LIB/gtk2 -Fu$LAZARUS_LIB_PKG -Fu./vpnmandriva/ -Fu. -ovpnmandriva -dLCL -dLCLgtk2 vpnmandriva.pas
if [ -f `which upx` ] 
then
  upx -9 ./vpnmandriva
fi
        