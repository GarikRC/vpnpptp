#!/bin/sh
cd ./modules
/usr/bin/fpc $(cat ./MyMessageBox.compiled | grep "Params Value" | cut -d\" -f2)
/usr/bin/strip -s ./mymessagebox

cd ..
cd ./mandriva_pptp
/usr/bin/fpc $(cat ./project1.compiled | grep "Params Value" | cut -d\" -f2)
/usr/bin/strip -s ./vpnpptp

cd ..
cd ./Pon_off
/usr/bin/fpc $( cat ./project1.compiled | grep "Params Value" | cut -d\" -f2)
/usr/bin/strip -s ./ponoff
