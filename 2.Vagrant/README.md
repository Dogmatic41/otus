# otus - Обновление ядра в OC Linux 
## Процесс обновления разделили на 3 группы.

### 1) Предварительные шаги

Выбрали образ Debian 12 который запускается на MacBook Air с чипом M1 и виртуализацией через VMware Fusion.

1. Подготовили vagrantfile для запуска с помощью vagrant.

```
Vagrant.configure("2") do |config|
  config.vm.define "deb11-test" do |srv|
    srv.vm.box = "bento/debian-12"
    srv.vm.box_version = "202401.31.0"
    srv.vm.provider :vmware_desktop do |vmware|
      vmware.gui = true
      vmware.cpus = 1
      vmware.memory = 1024 
      vmware.vmx["ethernet0.virtualdev"] = "vmxnet3"
      vmware.ssh_info_public = true
      vmware.linked_clone = false
    end
  end
end  
```
![Запуск образа через - vagrant up](https://github.com/Dogmatic41/otus/blob/main/2.Vagrant/image/Vagrant%20up.png?raw=true)

2. Подключени к образу и обновления ядра 

Для подключения к образу по ssh используется команда и сразу проверяем версию ядра.

```
vagrant ssh deb11-test
uname -r
```
Обновление ядра операционной системы использовали команду

```
sudo apt update
sudo apt upgrade
```
![Скриншот обновления проверки ядра и его обновления](https://raw.githubusercontent.com/Dogmatic41/otus/main/2.Vagrant/image/uname%20-r%20and%20sudo%20apt%20update.png)

3. Перезапуск системы и проверка ядра 

После успешного обновления мы перезапсукаем VM командой 
```
vagrant reload deb11-test
```
После перезапуска системы подключаемся и проверяем версию ядра
```
vagrant ssh deb11-test
uname -r
```
![Перезапуск VM и проверка версии ядра](https://github.com/Dogmatic41/otus/blob/main/2.Vagrant/image/after%20the%20update,%20restart%20%20VM.png?raw=true)