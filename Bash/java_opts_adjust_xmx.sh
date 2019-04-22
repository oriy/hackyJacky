#!/usr/bin/env bash

JAVA_OPTS_XMX_MB=$(echo "Xmx: ${JAVA_OPTS}" | sed -e 's/.*\-Xmx\([0-9]\+\)m.*/\1/g' -e 's/.*\-Xmx\([0-9]\+\)g.*/\1*1024/g' | bc)
MEMTOTAL_MB=$(awk '/MemTotal:/ { print $2/1024 }' /proc/meminfo | cut -d. -f1)
echo "Setting jvm memory::: Memory Total: ${MEMTOTAL_MB}MB, Requested Xmx: ${JAVA_ARG_XMX_MB} "

# setting minimal between requested xmx, leaving at least 15% or 1GB
XMX_MB=$(echo " \
    ${JAVA_OPTS_XMX_MB}
    $(echo "$MEMTOTAL_MB - 1024" | bc)
    $(echo "$MEMTOTAL_MB * 0.85" | bc)" \
    | sort -n | head -1 | sed -e 's/\..*//g' -e 's/\ //g')

echo "Memory Total: ${MEMTOTAL_MB}MB, Xms: ${XMX_MB}MB, Xmx: ${XMX_MB}MB"

#replacing xms and xmx with the available xmx possible
JAVA_OPTS=$(echo ${JAVA_OPTS} | sed -e 's/\"-Xm[xs][0-9]\+[mg]\"//g')
JAVA_OPTS=`eval echo -Xmx${XMX_MB}m -Xms${XMX_MB}m ${JAVA_OPTS}`
