# Otus - 34. DNS
## Настраиваем split-dns

Цель задания:

- взять стенд https://github.com/erlong15/vagrant-bind
- добавить еще один сервер client2
- завести в зоне dns.lab
- имена
- web1 - смотрит на клиент1
- web2 смотрит на клиент2
- завести еще одну зону newdns.lab
- завести в ней запись
- www - смотрит на обоих клиентов
- настроить split-dns
- клиент1 - видит обе зоны, но в зоне dns.lab только web1
- клиент2 видит только dns.lab

В предоставленном ansible-playbook были добавлены дополнительные модули.
```
  - name: Fix CentOS repository (step 1)
    shell: sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/CentOS*.repo

  - name: Fix CentOS repository (step 2)
    shell: sed -i s/^#.*baseurl=http/baseurl=http/g /etc/yum.repos.d/CentOS*.repo
  
  - name: Fix CentOS repository (step 3)
    shell: sed -i s/^mirrorlist=http/#mirrorlist=http/g /etc/yum.repos.d/CentOS*.repo
  
  - name: Update CentOS system
    shell: yum update -y

```
Были добавлены дополнительные репозитории для обновления системы и установки пакетов. 
После загрузки ВМ и выполения playbook все DNS имена пингует по заданию.