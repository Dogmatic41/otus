# otus - NFS, FUSE.
## Настраивае и использование NFS.
Задания: 
- vagrant up должен поднимать 2 виртуалки: сервер и клиент;
- на сервер должна быть расшарена директория;
- на клиента она должна автоматически монтироваться при старте (fstab или autofs);
- в шаре должна быть папка upload с правами на запись;

Для выполнения данных заданий были написано 2 ansible playbook nfsc-preparation.yml и nfss-preparation.yml.
- nfss-preparation.yml производит настройку nfs server.
- nfsc-preparation.yml производит настройку nfs client.