# otus - Инициализация системы. Systemd 
## Изучение состава и синтаксиса systemd unit;
Задания: 
- Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/sysconfig или в /etc/default).
- Установить spawn-fcgi и переписать init-скрипт на unit-файл (имя service должно называться так же: spawn-fcgi).
- Дополнить unit-файл httpd (он же apache2) возможностью запустить несколько инстансов сервера с разными конфигурационными файлами.

Для выполнения данных заданий были написано ansible playbook systemd.yml 
systemd.yml производит пошаговое выполнение заданий с выводом итогового результата по каждому заданию.
