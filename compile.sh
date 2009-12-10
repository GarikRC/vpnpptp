#!/bin/sh
cd ./mandriva_pptp
/usr/bin/fpc $(cat ./project1.compiled | grep "Params Value" | cut -d\" -f2)
/usr/bin/strip -s ./vpnpptp
#/usr/bin/upx -9 ./vpnpptp

cd ..
cd ./Pon_off
/usr/bin/fpc $( cat ./project1.compiled | grep "Params Value" | cut -d\" -f2)
/usr/bin/strip -s ./ponoff
#/usr/bin/upx -9 ./ponoff
