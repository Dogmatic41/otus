# Otus - 7. Практические навыки работы с ZFS
## Работа с ZFS 

Данный тестовый стенд был собран под виртуализацию на Virtual Box и использовался образ centos 7.
Вместо Bash скрипта был написан ansible-playbook.

Цели задания:

1. Определить алгоритм с наилучшим сжатием:
 - Определить какие алгоритмы сжатия поддерживает zfs (gzip, zle, lzjb, lz4);
 - создать 4 файловых системы на каждой применить свой алгоритм сжатия;
 - для сжатия использовать либо текстовый файл, либо группу файлов.
2. Определить настройки пула.
 - С помощью команды zfs import собрать pool ZFS.
 - Командами zfs определить настройки:
    - размер хранилища;
    - тип pool;
    - значение recordsize;
    - какое сжатие используется;
    - какая контрольная сумма используется.
3. Работа со снапшотами:
 - скопировать файл из удаленной директории;
 - восстановить файл локально. zfs receive;
 - найти зашифрованное сообщение в файле secret_message.

 ### 1.Определить алгоритм с наилучшим сжатием.
 Для выполнения данной задачи был создан ansible-playbook (zfs.yml).
 Playbook был разбит на 2 основные части , где 1 основной моменты мы проверяем все ли диски добавились которые были указаны в Vagrantfile. Playbook выводит нам все доступные диски , в нашем примере должны быть с /dev/sdb - /dev/sdi , после чего playbook уточняет продолжать все выполнение задачи или пропустить их.
 Второя часть посвещенна настройке zfs pool , настройки сжатия на каждый pool отдельно, скачивание лог файла и определению алгоритма с наилучшим сжатием.
 После выполнения данной части задания , нам выведет все 4 пула с лог файлом , где мы сможем опеределить наилучший алгоритм сжатия.
 P.S.
 Ответ - gzip-9

 ```
tasks:
  - name: Tasks.1  Display Disk Information
    debug:
      var: ansible_facts.devices.keys()

  - pause:
      prompt: "Do you want to configuring the zfs pool (yes/no)?"
    register: my_pause
    delegate_to: zfs

  - name: Tasks.1  Create pool
    command: zpool create {{ item.pool }} mirror {{ item.disk }} 
    with_items:
    - { pool: pool1, disk: /dev/sdb /dev/sdc }
    - { pool: pool2, disk: /dev/sdd /dev/sde }
    - { pool: pool3, disk: /dev/sdf /dev/sdg }
    - { pool: pool4, disk: /dev/sdh /dev/sdi }
    when: hostvars['zfs'].my_pause.user_input | bool

  - name: Tasks.1  Configuring the zfs pool
    command: zfs set compression={{ item.compressions }}  {{ item.pool }} 
    with_items:
    - { compressions: lzjb, pool: pool1 }
    - { compressions: lz4, pool: pool2 }
    - { compressions: gzip-9, pool: pool3 }
    - { compressions: zle, pool: pool4 }
    when: hostvars['zfs'].my_pause.user_input | bool

  - name: Tasks.1  Copy log file
    copy:
      src: "{{ item.src }}"
      dest: "{{ item.dest }}"
    loop:
    - src: ./pg2600.converter.log 
      dest: /pool1/
    - src: ./pg2600.converter.log 
      dest: /pool2/
    - src: ./pg2600.converter.log 
      dest: /pool3/
    - src: ./pg2600.converter.log 
      dest: /pool4/
    when: hostvars['zfs'].my_pause.user_input | bool

  - name: Tasks.1 zfs get all
    shell: zfs get all | grep compressratio | grep -v ref
    register: zfs_all
    when: hostvars['zfs'].my_pause.user_input | bool
  
  - debug: msg="{{ zfs_all.stdout }}"
 ```

  ### 2.Определение настроек пула.
  Для выполнения данной задачи был дополнен уже ранее созданный ansible-playbook (zfs.yml).
В процессе выполнения playbook мы скачивали каталог , разархивировали его и импортировали каталог в пул с полным выводом информации о данном пуле, где мы могли узнать все нас интересующие данные. А имеено:
    - размер хранилища; - otus  available  350M  
    - тип pool; - otus  readonly  off     default
    - значение recordsize; - otus  recordsize  128K     local
    - какое сжатие используется; - otus  compression  zle       local
    - какая контрольная сумма используется. - otus  checksum  sha256     local

  ```
  - name: Tasks.2  Download the file and unzip it
    unarchive:
      src: https://drive.usercontent.google.com/download?id=1MvrcEp-WgAQe57aDEzxSRalPAwbNN1Bb&export=download
      dest: /home/vagrant
      remote_src: yes

  - name: Tasks.2  Import otus pool
    command: zpool import -d zpoolexport/ otus

  - name: Tasks.2  ZPool status
    command: zpool get all otus
    register: zfs_status


  - debug: msg="{{ zfs_status.stdout }}"
  ```

  ### 3.Работа со снапшотами.

Мы скачивали файл указанный в задании

```
wget -O otus_task2.file --no-check-certificate https://drive.usercontent.google.com/download?id=1wgxjih8YZ-cqLqaZVa0lA3h3Y029c3oI&export=download
```

Восстанили файловую систему из снапшота

```
zfs receive otus/test@today < otus_task2.file
```

Далее ищем файл с именем “secret_message” и выводим его содержимое с помощью find

```
find /otus/test -name "secret_message" -exec cat {} \;

https://otus.ru/lessons/linux-hl/
```