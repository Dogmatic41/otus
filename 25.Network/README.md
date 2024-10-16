# Архитектура сетей

## Задание: разворачиваем сетевую лабораторию.

* построить следующую архитектуру

Сеть office1
- 192.168.2.0/26 - dev
- 192.168.2.64/26 - test servers
- 192.168.2.128/26 - managers
- 192.168.2.192/26 - office hardware

Сеть office2
- 192.168.1.0/25 - dev
- 192.168.1.128/26 - test servers
- 192.168.1.192/26 - office hardware


Сеть central
- 192.168.0.0/28 - directors
- 192.168.0.32/28 - office hardware
- 192.168.0.64/26 - wifi

```
Office1 ---\
-----> Central --IRouter --> internet
Office2----/
```
Итого должны получится следующие сервера
- inetRouter
- centralRouter
- office1Router
- office2Router
- centralServer
- office1Server
- office2Server

### Теоретическая часть
- Найти свободные подсети
- Посчитать сколько узлов в каждой подсети, включая свободные
- Указать broadcast адрес для каждой подсети
- проверить нет ли ошибок при разбиении

### Практическая часть
- Соединить офисы в сеть согласно схеме и настроить роутинг
- Все сервера и роутеры должны ходить в инет черз inetRouter
- Все сервера должны видеть друг друга
- у всех новых серверов отключить дефолт на нат (eth0), который вагрант поднимает для связи
- при нехватке сетевых интервейсов добавить по несколько адресов на интерфейс

## Решение

### Проект сетевой конфигурации организации.

* В списке указаны используемые подсети, *broadcast* и *gateway* адреса, маски,  количество узлов, неиспользованные подсети

#### Сеть office1

```
- 192.168.2.0/26 - dev   (off1_dev)
    62 узла
    
    192.168.2.1 - gw 
    192.168.2.63 - brd 
    255.255.255.192 - netmask

- 192.168.2.64/26 - test servers (off1_tst)
    62 узла

    192.168.2.65 - gw 
    192.168.2.127 - brd 
    255.255.255.192 - netmask

- 192.168.2.128/26 - managers (off1_mng)
    62 узла

    192.168.2.129 - gw 
    192.168.2.191 - brd 
    255.255.255.192 - netmask

- 192.168.2.192/26 - office hardware (off1_hrd)
    62 узла

    192.168.2.193 - gw 
    192.168.2.255 - brd
    255.255.255.192 - netmask 

- Свободных подсетей нет

- 192.168.255.4/30 - router  (off1_rtr)
    2 узла

    192.168.255.5 - gw 
    192.168.255.7 - brd
    255.255.255.252 - netmask 
```
#### Сеть office2

```
- 192.168.1.0/25 - dev (off2_dev)
    126 узлов

    192.168.1.1 - gw 
    192.168.1.127 - brd
    255.255.255.128 - netmask 

- 192.168.1.128/26 - test servers (off2_tst)
    62 узла
    
    192.168.1.129 - gw 
    192.168.1.191 - brd
    255.255.255.192 - netmask 

- 192.168.1.192/26 - office hardware (off2_hrd)
    62 узла

    192.168.1.193 - gw 
    192.168.1.255 - brd
    255.255.255.192 - netmask 

- Свободных подсетей нет

- 192.168.255.8/30 - router (off2_rtr)
    2 узла

    192.168.255.9 - gw 
    192.168.255.11 - brd
    255.255.255.252 - netmask 
```

#### Сеть central

```
- 192.168.0.0/28 - directors   (cntrl_dir)
    14 узлов

    192.168.0.1 - gw
    192.168.0.15 - brd
    255.255.255.240 - netmask

- 192.168.0.32/28 - office hardware (cntrl_hrd)
    14 узлов

    192.168.0.33 - gw
    192.168.0.47 - brd
    255.255.255.240 - netmask

- 192.168.0.64/26 - wifi  (cntrl_wf)
    62 узла

    192.168.0.65 -  gw
    192.168.0.127 - brd
    255.255.255.192 - netmask

- Свободные подсети: 
    192.168.0.16/28 (14 узлов)
    192.168.0.48/28 (14 узлов)
    192.168.0.128/25 (126 узлов)

- 192.168.255.0/30 - router (cntrl_rtr)
    2 узла

    192.168.255.1 - gw 
    192.168.255.3 - brd
    255.255.255.252 - netmask 
```

### Настройка стенда.

* В репозиторий **GitHUB** добавлен [Vagrant файл](https://github.com/Dogmatic41/otus/blob/main/25.Network/Vagrantfile),  который  разворачивает требуемый стенд из 7 виртуалок , а полную настройку сетей на ВМ производим через ansible playbook [network.yml](https://github.com/Dogmatic41/otus/blob/main/25.Network/network.yml)
