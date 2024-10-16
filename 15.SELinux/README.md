# SELinux
[img1]: https://github.com/Dogmatic41/otus/blob/main/15.SELinux/images/port%204881.png "" 
[img2]: https://github.com/Dogmatic41/otus/blob/main/15.SELinux/images/port%204882.1.png "" 
[img3]: https://github.com/Dogmatic41/otus/blob/main/15.SELinux/images/port%204882.2.png "" 
[img4]: https://github.com/Dogmatic41/otus/blob/main/15.SELinux/images/port%204883.png "" 



## Задача 1. Запуск nginx на нестандартном порту

* Запустить nginx на нестандартном порту 3-мя разными способами:
- переключатели setsebool;
- добавление нестандартного порта в имеющийся тип;
- формирование и установка модуля SELinux.

### Решение 

* Подготавливаем Vagrant стенд на **centos/7**, устанавливаем **nginx**, устанавливаем **policycoreutils-python** и **setroubleshoot** для анализа журналов аудита.
[Vagrant файл](https://github.com/Dogmatic41/otus/blob/main/15.Network/Vagrantfile)
По умолчанию **SELinux** работает в статусе **Enforcing**. 
В конфигурационном файле **nginx** устанавливается порт **4881** и выполняем запуск приложения, которая падает в ошибку. Выполняем проверку журнала аудита посредством запуска команды.
```
sealert -a /var/log/audit/audit.log
```
Вывод команды указывает на ошибку по нестандартному порту и так же предлагает 3 варианта решение проблемы. 
Выполняем добавление нестандартного порта в имеющийся тип.
```
semanage port -a -t http_port_t -p tcp 4881
```
В результате **nginx** успешно стартовал.

![добавление порта][img1]

* Далее в конфигурации **nginx** снова меняем порт и перезапускаем службу **nginx**
```
sed -ie 's/:4881/:4882/g' /etc/nginx/nginx.conf
sed -i 's/listen       4881;/listen       4882;/' /etc/nginx/nginx.conf
systemctl restart nginx && systemctl status nginx
```
Повторно смотрим журнал и вносим изменения.
```
sealert -a /var/log/audit/audit.log
setsebool -P nis_enabled 1
```

![переключатель setsebool][img2]
![переключатель setsebool][img3]

* Далее в конфигурации **nginx** снова меняем порт и перезапускаем службу **nginx**
```
sed -ie 's/:4882/:4883/g' /etc/nginx/nginx.conf
sed -i 's/listen       4882;/listen       4883;/' /etc/nginx/nginx.conf
systemctl restart nginx && systemctl status nginx
```
Повторно смотрим журнал и выполняем установка модуля SELinux
```
ausearch -c 'nginx' --raw | audit2allow -M my-nginx_20200
semodule -i my-nginx_20200.pp
``` 

![установка модуля][img4]

## Задача 2. Устранение проблемы с удаленным обновлением зоны DNS

- Развернуть [приложенный стенд](https://github.com/mbfx/otus-linux-adm/tree/master/selinux_dns_problems)
- Выяснить причину неработоспособности механизма обновления зоны;
- Предложить решение (или решения) для данной проблемы;
- Выбрать одно из решений для реализации, предварительно обосновав выбор;
- Реализовать выбранное решение и продемонстрировать его работоспособность.

### Решение 

* Разворачиваем vagrant стенд из 2 хостов, на которых  ansible-plabook выполняется установка и настройка **dns** (сервер и клиент). На клиентском хосте выполняется попытка обновления зоны, которая падает в ошибку.
```
[root@client vagrant]# nsupdate -k /etc/named.zonetransfer.key
> server 192.168.50.10
> zone ddns.lab
> update add www.ddns.lab. 60 A 192.168.50.15
> send
update failed: SERVFAIL
> quit
```

При изучение журнала аудита 
```
audit2why < /var/log/audit/audit.log
``` 
находим что SELinux отказывает процессу **isc-worker0000** в изменении файла 
```
/etc/named/dynamic/named.ddns.lab.view1.jnl
```

Чтобы выяснить причину запрета в предустановленной политике - выполняется вывод правил для **named**
```
semanage fcontext -l | grep named
```
Видно что в правилах разрешено изменение файлов внутри папки **/var/named/dynamic** в то время как в текущей конфигурации они расположены по пути **/etc/named/dynamic**. 
Есть 2 варианта решения данной проблемы:

1)Изменить тип контекста безопасности для каталога /etc/named: 
```
sudo chcon -R -t named_zone_t /etc/named
```
2)Настройка производилась из playbook , то необходимо исправить пути с **/etc/named** на **/var/named**.
