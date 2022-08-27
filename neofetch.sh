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
# Disk
while read line ; do
  read line disk use a b c
  case $line in 
    /dev/ )line=${line#* } && break ;;
  esac
done < <(df -h /)
echo "-> Disk usage: ${use}/${disk} (${b}) "

# CPU usage
awk '{u=$2+$4; t=$2+$4+$5; if (NR==1){u1=u; t1=t;} else print ($2+$4-u1) * 100 / (t-t1) "%"; }' \
<(grep 'cpu ' /proc/stat) <(sleep 1;grep 'cpu ' /proc/stat)
