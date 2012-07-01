#!/bin/bash

if [ -z "$(env | grep USER=root)" ];then
	echo "You're not the root!"
	exit 1
fi

if [ $# -ne 1 ];then
	echo "One and only one pptp config file needed"
	exit 1
fi

if [ -n "$(/usr/bin/strings /usr/sbin/pppd|grep require-mppe)" ];then
	cd /etc/ppp/peers
	sed '/^mppe /d' $1 >.__temp_$1
 
	if [ -n "$(grep required $1)" ];then
		echo 'require-mppe' >> .__temp_$1
	fi	

	if [ -n "$(grep stateless $1)" ];then
		echo 'nomppe-stateful' >> .__temp_$1
	fi
	
	if [ -n "$(grep no40 $1)" ];then
		echo 'nomppe-40' >> .__temp_$1
	fi
	
	if [ -n "$(grep no128 $1)" ];then
		echo 'nomppe-128' >> .__temp_$1
	fi	
	
	mv .__temp_$1 $1
fi

exit 0
