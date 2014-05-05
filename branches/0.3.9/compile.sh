#!/bin/bash

cd ./modules

lazbuild ./MyMessageBox.lpi
if [ ! -f ./MyMessageBox ]
then
   echo "Compillation MyMessageBox error!"
   exit 0
fi

cd ..
cd ./vpnpptp

lazbuild ./vpnpptp.lpi
if [ ! -f ./vpnpptp ]
then
   echo "Compillation vpnpptp error!"
   exit 0
fi

cd ..
cd ./ponoff

lazbuild ./ponoff.lpi
if [ ! -f ./ponoff ]
then
   echo "Compillation ponoff error!"
   exit 0
fi

cd ..
cd ./vpnmcc

lazbuild ./vpnmcc.lpi
if [ ! -f ./vpnmcc ]
then
   echo "Compillation vpnmcc error!"
   exit 0
fi
