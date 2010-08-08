#!/bin/sh
mkdir -p /opt/vpnpptp/
cp -f ./success /opt/vpnpptp/
cp -f ./mandriva_pptp/vpnpptp /opt/vpnpptp/
cp -f ./Pon_off/ponoff /opt/vpnpptp/
ln -s /opt/vpnpptp/ponoff /usr/bin/ponoff