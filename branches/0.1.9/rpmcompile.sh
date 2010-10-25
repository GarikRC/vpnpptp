#!/bin/sh

cd ./modules
/usr/bin/fpc $(cat ./MyMessageBox.compiled | grep "Params Value" | cut -d\" -f2)
/usr/bin/strip -s ./mymessagebox
cd ..
cd ./vpnpptp
/usr/bin/fpc $(cat ./project1.compiled | grep "Params Value" | cut -d\" -f2) -Fu../modules/
/usr/bin/strip -s ./vpnpptp
cd ..
cd ./ponoff
/usr/bin/fpc $( cat ./project1.compiled | grep "Params Value" | cut -d\" -f2) -Fu../modules/
/usr/bin/strip -s ./ponoff