#!/bin/bash
mkdir -p ~root/.ssh
  cp ~vagrant/.ssh/auth* ~root/.ssh
yum install -y mdadm smartmontools hdparm gdisk
sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
sudo mdadm --create --verbose /dev/md0 -l 5 -n 5 /dev/sd{b,c,d,e,f}

while  [ "$(sudo mdadm -D /dev/md0 | grep "Rebuild Status")" ] ; do
  echo "...rebuilding RAID. Rebuild status : $(sudo mdadm -D /dev/md0 | grep "Rebuild Status" | awk '{print $4}')"
  sleep 1
done
echo "RAID rebuild done"

echo "$(sudo mdadm -D /dev/md0) | grep "Raid Level")" &&
echo "$(sudo mdadm -D /dev/md0) | grep "Array Size")" &&
echo "$(sudo mdadm -D /dev/md0) | grep "Raid Devices")" &&

sudo mkdir /etc/mdadm
sudo sh -c 'echo "DEVICE partitions" > /etc/mdadm/mdadm.conf'
sudo sh -c 'sudo mdadm --detail --scan --verbose | grep ARRAY >> /etc/mdadm/mdadm.conf'
echo "--- FIN ---"
