#!/bin/bash

yum install mdadm -y

# Создаем массив RAID 10 с 5 дисками 
mdadm --create --verbose /dev/md0 -l 10 -n 5 /dev/sd{b,c,d,e,f}

# Проверяем статус созданного массива
mdadm --detail /dev/md0

# Создаем файл конфигурации mdadm.conf
echo "DEVICE partitions" > /etc/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >>/etc/mdadm.conf

# Обновляем initramfs
mkinitrd

# Перезагружаем систему
reboot