# Otus - 6. Файловые системы и LVM
## Работа с LVM

Данный тестовый стенд был собран под виртуализацию на Virtual Box и использовался образ centos 7.

Цели задания:

1. уменьшить том под / до 8G
2. выделить том под /home
3. выделить том под /var (/var - сделать в mirror)
4. для /home - сделать том для снэпшотов
5. Работа со снапшотами:
 - сгенерировать файлы в /home/
 - снять снэпшот
 - удалить часть файлов
 - восстановиться со снэпшотаv

 ### 1. Уменьшить том под / до 8G

 Для выполнения данный задачи разабьем ее на 3 подзадачи.
 
1. Создаем временный раздел на новом томе LVM. Переносим корневой раздел на временный том и загружаемся с него.
2. Уменьшаем исходный том до нужного размера, возвращаем на него данные. 
3. Удаляем временный том.

#### 1.1 Создание временного раздела.
Перед началом работы необходимо установить xfsdump.
Далее подготавливаем временный раздел root.
```
pvcreate /dev/sdb
vgcreate vg_root /dev/sdb
lvcreate -l +100%FREE -n lv_root /dev/vg_root
```

Создадим файловую систему XFS и смонтируем ее в каталог /mnt:

```
mkfs.xfs /dev/vg_root/lv_root
mount /dev/vg_root/lv_root /mnt
```

Затем смотрим расположение корневого раздела и дампим содержимое текущего корневого раздела в наш временный
```
lvdisplay
xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt
```

Далее сконфигурируем grub для того, чтобы при старте перейти в новый root.
```
for i in /proc/ /sys/ /dev/ /run/ /boot/; \
do mount --bind $i /mnt/$i; done

chroot /mnt/

grub2-mkconfig -o /boot/grub2/grub.cfg
```

Обновляем образы загрузки:
```
cd /boot ; for i in `ls initramfs-*img`; \
do dracut -v $i `echo $i|sed "s/initramfs-//g; \
> s/.img//g"` --force; done
```
Ну и для того, чтобы при загрузке был смонтирован нужны root нужно в файле
/boot/grub2/grub.cfg заменить rd.lvm.lv=VolGroup00/LogVol00 на rd.lvm.lv=vg_root/lv_root

Выходим из окружения chroot и перезагружаем компьютер.
#### 1.2 Уменьшение исходного тома. 
И так, у нас есть раздел, который нужно уменьшить и который теперь не примонтирован в качестве корня.

Удаляем его логический том:
```
lvremove /dev/VolGroup00/LogVol00
```
Создаем новый логический том меньшего размера:
```
lvcreate -n VolGroup00/LogVol00 -L 8G /dev/VolGroup00
```
И повторяем те же действия которые указаны в пункте 1.1
#### 1.3 Удаление временного тома.

Для порядка, вернем прежнее состояние без временного тома.

Удаляем том, группу и снимаем lvm-метку с диска, который нами использовался как временный (sdb):

```
lvremove /dev/vg_root/lv_root

vgremove vg_root

pvremove /dev/sdb
```

 ### 2. Выделить том под /home.

 Выделяем том под /home:
```
lvcreate -n LogVol_Home -L 2G /dev/VolGroup00
mkfs.xfs /dev/VolGroup00/LogVol_Home
mount /dev/VolGroup00/LogVol_Home /mnt/
cp -aR /home/* /mnt/
rm -rf /home/*
umount /mnt
mount /dev/VolGroup00/LogVol_Home /home/
```
Правим fstab для автоматического монтирования /home:
```
echo "`blkid | grep Home | awk '{print $2}'` \
 /home xfs defaults 0 0" >> /etc/fstab
```

### 3. Выделить том под /var (/var - сделать в mirror).

Выделить том под /var в зеркало
На свободных дисках создаем зеркало:

```
pvcreate /dev/sdc /dev/sdd
vgcreate vg_var /dev/sdc /dev/sdd
lvcreate -L 950M -m1 -n lv_var vg_var
mkfs.ext4 /dev/vg_var/lv_var
mount /dev/vg_var/lv_var /mnt
cp -aR /var/* /mnt/
```
Монтируем новый var в каталог /var:
```
umount /mnt
mount /dev/vg_var/lv_var /var
```
Правим fstab для автоматического монтирования /var:
```
echo "`blkid | grep var: | awk '{print $2}'` \
 /var ext4 defaults 0 0" >> /etc/fstab
```

### 4. для /home - сделать том для снэпшотов.
```
lvcreate -L500 -s -n sn01 /dev/VolGroup00/LogVol_Home
```
данная команда помечает, что 500 Мб дискового пространства устройства /dev/VolGroup00/LogVol_Home будет использоваться для snapshot (опция -s).

### 5. Работа со снапшотами.

Генерируем файлы в /home/:
```
touch /home/file{1..10}
```
Снять снапшот:
```
lvcreate -L100 -s -n home_snap /dev/VolGroup00/LogVol_Home
```
Удалить часть файлов:
```
rm -f /home/file{1..5}
```
Процесс восстановления из снапшота:
```
umount /home
lvconvert --merge /dev/VolGroup00/home_snap
mount /home
ls -al /home
```