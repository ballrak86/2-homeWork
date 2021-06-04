------------------------------------------------------------
Описание файлов в директории
logFileFull.log - полный лог выполнения
used_commands.txt - команды которые использовал

Vagrant_folder - все что понадобится для поднятия VM и краткое описание файлов в ней
Vagrantfile - вагрант файл
provisionscript.sh - скрипт настройки и монтирования RAID 6

------------------------------------------------------------
Описание как запустить виртуальную машину (кратко)
Выполнить команду
vagrant up
во время поднятия ВМ выполняется скрипт provisionscript.sh и ВМ перезагружается
vagrant ssh
 проверяем что рейд исправен а так же что диски подмонтированы
 sudo -i
 mdadm -D /dev/md0
 mount | grep -F '/raid/part'

------------Vagrantfile (только интересные моменты)------------
#в ВМ выполняем наш скрипт
box.vm.provision "shell", path: "provisionscript.sh"

------------provisionscript.sh------------
#!/bin/bash
#Чистим суперблок на дисках
mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
#Создаем рейд
mdadm --create --verbose /dev/md0 -l 6 -n 5 /dev/sd{b,c,d,e,f}
#Проверяем что рейд собран
cat /proc/mdstat
mdadm -D /dev/md0
mdadm --detail --scan --verbose
mkdir /etc/mdadm/
#создаем конфиг файл mdadm.conf и наполняем его чтобы рейд собрался после перезагрузки
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
echo "cat /etc/mdadm/mdadm.conf"
cat /etc/mdadm/mdadm.conf
#помечаем диск как сбойный
mdadm /dev/md0 --fail /dev/sde
echo "cat /proc/mdstat"
cat /proc/mdstat
echo "mdadm -D /dev/md0"
mdadm -D /dev/md0
sleep 20
#удаляем из рейд сбойный диск
mdadm /dev/md0 --remove /dev/sde
mdadm --zero-superblock --force /dev/sde
#добавляем диск в рейд
mdadm /dev/md0 --add /dev/sde
echo "cat /proc/mdstat"
cat /proc/mdstat
echo "mdadm -D /dev/md0"
mdadm -D /dev/md0
#создаем на рейд таблицу gpt
parted -s /dev/md0 mklabel gpt
#создаем разделы на рейд диске
parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 40%
parted /dev/md0 mkpart primary ext4 40% 60%
parted /dev/md0 mkpart primary ext4 60% 80%
parted /dev/md0 mkpart primary ext4 80% 100%
#создаем на них файловую систему
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done
#Создаем директории для монтирования
mkdir -p /raid/part{1,2,3,4,5}
#Наполняем fstab чтобы при перезагрузки диски подмонтировались
for i in $(seq 1 5); do echo /dev/md0p$i /raid/part$i ext4 defaults 0 0 >> /etc/fstab; done
#Монтируем диски
for i in $(seq 1 5); do mount /raid/part$i; done
#Проверяем что все смонтировано
echo "show mounted raid parts"
mount | grep -F "/raid/part"
#Перезагружаем ВМ
shutdown -r now