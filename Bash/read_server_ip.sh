#!/usr/bin/env bash

echo -n "Type the IP address of the server and press [ENTER]:"
read ip_server
while [ $(echo ${ip_server} | egrep -c "10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}") -lt 1 ]
do
	read -p "Retype the PRIVATE IP address of the server and press [ENTER]:" ip_server
done