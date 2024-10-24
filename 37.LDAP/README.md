# Otus - 37. LDAP
## Научиться настраивать LDAP-сервер и подключать к нему LDAP-клиентов.

Цель задания:
1) Установить FreeIPA
2) Написать Ansible-playbook для конфигурации клиента

Входе выполнения ДЗ был написан ansible-playbook ldap.yml который настраивает на сервере ldap и подготавливает клиенты.

### Создание пользователя в ldap
![Скорость iperf3 в режиме tap](https://github.com/Dogmatic41/otus/blob/main/37.LDAP/images/create_user.png)

### Входим под созданным пользователем на клиенте 
![Скорость iperf3 в режиме tun](https://github.com/Dogmatic41/otus/blob/main/37.LDAP/images/client_host.png)