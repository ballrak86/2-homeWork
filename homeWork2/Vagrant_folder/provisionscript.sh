#!/bin/bash
mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
mdadm --create --verbose /dev/md0 -l 6 -n 5 /dev/sd{b,c,d,e,f}
cat /proc/mdstat
mdadm -D /dev/md0
mdadm --detail --scan --verbose
mkdir /etc/mdadm/
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
echo "cat /etc/mdadm/mdadm.conf"
cat /etc/mdadm/mdadm.conf
mdadm /dev/md0 --fail /dev/sde
echo "cat /proc/mdstat"
cat /proc/mdstat
echo "mdadm -D /dev/md0"
mdadm -D /dev/md0
sleep 20
mdadm /dev/md0 --remove /dev/sde
mdadm --zero-superblock --force /dev/sde
mdadm /dev/md0 --add /dev/sde
echo "cat /proc/mdstat"
cat /proc/mdstat
echo "mdadm -D /dev/md0"
mdadm -D /dev/md0
parted -s /dev/md0 mklabel gpt
parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 40%
parted /dev/md0 mkpart primary ext4 40% 60%
parted /dev/md0 mkpart primary ext4 60% 80%
parted /dev/md0 mkpart primary ext4 80% 100%
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done
mkdir -p /raid/part{1,2,3,4,5}
for i in $(seq 1 5); do echo /dev/md0p$i /raid/part$i ext4 defaults 0 0 >> /etc/fstab; done
for i in $(seq 1 5); do mount /raid/part$i; done
echo "show mounted raid parts"
mount | grep -F "/raid/part"
shutdown -r now