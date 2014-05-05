#! /bin/bash

#clean
cd modules
rm -f *.bak
rm -f *.bak1
rm -f *.o
rm -f *.ppu
rm -f wget*
rm -f compile.log
rm -f *log.txt
rm -f *.a
rm -f *.dbg
rm -f backup/*
cd ..

cd ponoff
rm -f *.bak
rm -f *.bak1
rm -f *.o
rm -f *.ppu
rm -f wget*
rm -f compile.log
rm -f *log.txt
rm -f *.a
rm -f *.dbg
rm -f backup/*
cd ..

cd vpnmcc
rm -f *.bak
rm -f *.bak1
rm -f *.o
rm -f *.ppu
rm -f wget*
rm -f compile.log
rm -f *log.txt
rm -f *.a
rm -f *.dbg
rm -f backup/*
cd ..

cd vpnpptp
rm -f *.bak
rm -f *.bak1
rm -f *.o
rm -f *.ppu
rm -f wget*
rm -f compile.log
rm -f *log.txt
rm -f *.a
rm -f *.dbg
rm -f backup/*
cd ..

#create POT files and update ponoff.ru.po, vpnpptp.ru.po
if [ -f "./ponoff/lang/ponoff.po" ]
then
  sed -i -e "s|#209|р|g" ./ponoff/lang/ponoff.po
  cp -f ./ponoff/lang/ponoff.po ./lang/ponoff.ru.po
  mv -f ./ponoff/lang/ponoff.po ./ponoff/lang/ponoff.pot
fi
if [ -f "./vpnmcc/lang/vpnmcc.po" ]
then
  sed -i -e "s|#209|р|g" ./vpnmcc/lang/vpnmcc.po
  mv -f ./vpnmcc/lang/vpnmcc.po ./vpnmcc/lang/vpnmcc.pot
fi
if [ -f "./vpnpptp/lang/vpnpptp.po" ]
then
  sed -i -e "s|#209|р|g" ./vpnpptp/lang/vpnpptp.po
  cp -f ./vpnpptp/lang/vpnpptp.po ./lang/vpnpptp.ru.po
  mv -f ./vpnpptp/lang/vpnpptp.po ./vpnpptp/lang/vpnpptp.pot
fi

#delete binary
rm -f modules/MyMessageBox
rm -f ponoff/ponoff
rm -f vpnmcc/vpnmcc
rm -f vpnpptp/vpnpptp
