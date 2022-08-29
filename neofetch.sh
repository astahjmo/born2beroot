#!/bin/bash

# Archteture
arch=$(uname -svo)
# Memory info file
memory=/proc/meminfo
processor=/proc/cpuinfo
cpu=/proc/stat
echo "
  ______   _       _     
 |  ____| | |     | |    
 | |__ ___| |_ ___| |__  
 |  __/ _ \ __/ __| '_ \ 
 | | |  __/ || (__| | | |
 |_|  \___|\__\___|_| |_| 
"
# Architecture //
echo "-> Arch: $arch"
# Processor
echo "-> CPU: $(cat $processor | grep "physical id"| sort | uniq | wc -l)"
echo "-> VCPU: $(cat $processor | grep -c "processor"| uniq)"
#MemInfo: proc/meminfo
while read line ; do
	case $line in
		MemTot*) line=${line#*:} && max_ram=$((${line% kB}/1024)) ;;
    MemAvail*:*) line=${line#*:} && cur_ram=$((${max_ram} - (${line% kB}/1024))) && break ;;
	esac
done < "$memory"
percent=$(echo $(bc -l <<< "scale=2; $cur_ram / $max_ram * 100"))
echo "-> Memory: ${cur_ram}/${max_ram}M (${percent}%)"
# Disk"
echo "-> Disk usage: $(df -h --total | grep "total" | awk '{print $3 "/" $2, "("$5")"}')"
# CPU usage
cpu_idle=`top -b -n 1 | grep Cpu | awk '{print $8}'|cut -f 1 -d "."`
echo "-> Cpu usage: $(bc -l <<< "100 - $cpu_idle")%"
# last boot
echo "-> Last boot: $(who -b | awk '{printf $3" "$4}')"
# LVM
echo "-> LVM:" $(cat /etc/fstab | grep '/dev/(mapper/|disk/by-id/dm)' && echo 'Yes' || echo 'No')
# TCP connection
echo "-> Connections TCP: $(netstat -natu | grep 'ESTABLISHED' | wc -l) ESTABLISHED"
# Users Logged
echo "-> Users logged: $(who | wc -l )"
# MAC-ADDRESS
echo "-> Network: $(ifconfig | grep "inet"| awk 'NR==1{print $2}') $(cat /sys/class/net/*/address | awk 'NR==1{print "("$1")"}')"
# SUDO
echo "-> Sudo: $(cat /var/log/sudo | wc -l) commands"
