# Otus - 3. Ansible
## Ознакомление с ansible и написание первого playbook
Данный тестовый стенд был собран под виртуализацию на VMware Fusion и использовался образ Debian 12 работающий на MacBook Air с чипом M1.

Цели задания:

1. Подготовить стенд на Vagrant
2. Необходимо использовать модуль yum/apt
3. Конфигурационный файлы должны быть взяты из шаблона jinja2 с переменными
4. После установки nginx должен быть в режиме enabled в systemd
5. Должен быть использован notify для старта nginx после установки
6. Сайт должен слушать на нестандартном порту - 8080, для этого использовать переменные в Ansible

### 1. Подготовить стенд на Vagrant
Использовался vagrantfile указананный в методичке.
```
MACHINES = {
  :nginx => {
        :box_name => "bento/debian-12",
        :vm_name => "nginx",
        :net => [
           ["192.168.11.150",  2, "255.255.255.0", "mynet"],
        ]
  }
}

Vagrant.configure("2") do |config|

  MACHINES.each do |boxname, boxconfig|

    config.vm.define boxname do |box|
   
      box.vm.box = boxconfig[:box_name]
      box.vm.host_name = boxconfig[:vm_name]
      
      box.vm.provider "vmware_desktop" do |v|
        v.gui = true
        v.memory = 1024
        v.cpus = 1
       end

      boxconfig[:net].each do |ipconf|
        box.vm.network("private_network", ip: ipconf[0], adapter: ipconf[1], netmask: ipconf[2], vmware_desktop__intnet: ipconf[3])
      end

      if boxconfig.key?(:public)
        box.vm.network "public_network", boxconfig[:public]
      end

      box.vm.provision "shell", inline: <<-SHELL
        mkdir -p ~root/.ssh
        cp ~vagrant/.ssh/auth* ~root/.ssh
        sudo sed -i 's/\#PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
        systemctl restart sshd
      SHELL
    end
  end
end
```
### 2. Необходимо использовать модуль yum/apt
При написание ansible-playbook внесли задачу на установку nginx на сервере используя модуль apt.
```
  tasks:
  - name: Install nginx
    apt:
      name: nginx
      state: latest
    notify:
    - started nginx
    - replacing the html file
    tags:
    - nginx-package
```
### 3. Конфигурационный файлы должны быть взяты из шаблона jinja2 с переменными
Взяди конфиг файл из шаблона jinja2 и переместили его в каталог templates находящийся на локальном хосте.
```
events {
    worker_connections 1024;
}

http {
    server {
        listen       {{ nginx_listen_port }} default_server;
        server_name  default_server;
        root         /usr/share/nginx/html;

        location / {
        }
    }
}

```
Так же прописали в playbook откуда взять и куда поместить данный конфиг и внесли переменную nginx_listen_port которая при исполнение ansible-playbook поставляло нужное значение.
```
  - name: Create nginx config file from template
    template:
      src: templates/nginx.conf.j2
      dest: /etc/nginx/nginx.conf
    notify:
    - restarted nginx
    tags:
    - nginx-configuration 
```
### 4. После установки nginx должен быть в режиме enabled в systemd.

Создали в handlers задание для запуска службы в режиме enabled в systemd.
```
  handlers:
  - name: started nginx
    systemd:
      name: nginx
      state: started
      enabled: yes
```
### 5.Должен быть использован notify для старта nginx после установки
Внесли раздел handlers и использовали notify при установке nginx и добавление nginx.conf.j2
```
  - name: Install nginx
    apt:
      name: nginx
      state: latest
    notify:
    - started nginx
    - replacing the html file
    tags:
    - nginx-package

  - name: Create nginx config file from template
    template:
      src: templates/nginx.conf.j2
      dest: /etc/nginx/nginx.conf
    notify:
    - restarted nginx
```
### 6. Сайт должен слушать на нестандартном порту - 8080, для этого использовать переменные в Ansible
В данном пунке была внесена переменная - nginx_listen_port: 8080
которая подставляется в конфиг файла jinja2.