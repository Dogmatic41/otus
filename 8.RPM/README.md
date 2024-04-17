# otus - Управление пакетами. Дистрибьюция софта 
## Cобрать собственный RPM пакет и разместить его в собственном репозитории.

### 1 Создать свой RPM 

Был собран тестовый стенд через Vagrant на OS Centos 7 и создание собственного ansible rpm пакета.

1) Установка необходимых пакетов:
```
sudo yum install -y rpm-build make python3-devel
```
2) Создание структуры каталогов:

Создайте структуру каталогов для сборки пакета:

```
mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
```

3) Загрузка исходного кода Ansible:
Взял версию Ansible 2.9.9.
```
cd ~/rpmbuild/SOURCES
curl -O https://releases.ansible.com/ansible/ansible-2.9.9.tar.gz
```

4) Создание файла .spec для RPM пакета:

Создал файл .spec в каталоге SPECS. Этот файл содержит информацию о сборке пакета, его зависимостях и дополнительные инструкции.

```
Name:           ansible
Version:        2.9.9
Release:        1%{?dist}
Summary:        Powerful automation tool for configuration management and more

License:        GPLv3
URL:            https://www.ansible.com
Source0:        https://releases.ansible.com/ansible/ansible-%{version}.tar.gz

BuildRequires:  python3-devel

%description
Ansible is a radically simple IT automation platform that makes your applications and systems easier to deploy.
Requires: python3-jinja2
Requires: python3-yaml

%prep
%setup -q

%build
python3 setup.py build

%install
python3 setup.py install --root=%{buildroot}

%files
%{_bindir}/ansible
%{python3_sitelib}/ansible/
%{_bindir}/ansible-config
%{_bindir}/ansible-connection
%{_bindir}/ansible-console
%{_bindir}/ansible-doc
%{_bindir}/ansible-galaxy
%{_bindir}/ansible-inventory
%{_bindir}/ansible-playbook
%{_bindir}/ansible-pull
%{_bindir}/ansible-test
%{_bindir}/ansible-vault
/usr/lib/python3.6/site-packages/ansible-2.9.9-py3.6.egg-info
/usr/lib/python3.6/site-packages/ansible_test

- Initial build
```

5) Сборка RPM пакета:

Теперь можно выполнить сборку пакета:
```
rpmbuild -ba ~/rpmbuild/SPECS/ansible.spec
```
6) Установка собранного пакета:

После успешной сборки пакета, найдем RPM файлы в каталоге ~/rpmbuild/RPMS. Установить собранный пакет спомощью команды:
```
sudo yum localinstall -y ~/rpmbuild/RPMS/x86_64/ansible-2.9.9-1.el7.x86_64.rpm
```

7) Проверка установки:

Проверьте, что Ansible установлен правильно:
```
ansible --version
```
Для корректоной работы Ansible необходимо установить на сервер python3 и модули jinja2 (pip3 install jinja2) и yaml (pip3 install pyyaml)

### 2. Создать свой репо и разместить там свой RPM;
Для созднания своей репозитории и размещение там ansible.rpm необходимо установить nginx и создать свою директорию.
```
yum install nginx
mkdir /usr/share/nginx/html/repo
```

Копируем в созданную директорию свой rpm файл и с помощью createrepo создаем репозиторию.

```
cp ~/rpmbuild/RPMS/x86_64/ansible-2.9.9-1.el7.x86_64.rpm /usr/share/nginx/html/repo
createrepo /usr/share/nginx/html/repo/
```

Далее для доступа через nginx к нашему rpm файлу , необходимо приписать в конфиге nginx добавить строчку autoindex on;

```
location / {
    root /usr/share/nginx/html;
    index index.html index.htm;
    autoindex on;
}
```
Далее curl проверяем доступен наш rpm через nginx 

```
curl -a http://localhost/repo/
```
И видим ответ 
```
<html>
<head><title>Index of /repo/</title></head>
<body>
<h1>Index of /repo/</h1><hr><pre><a href="../">../</a>
<a href="repodata/">repodata/</a>                                          17-Apr-2024 15:30                   -
<a href="ansible-2.9.9-1.el7.x86_64.rpm">ansible-2.9.9-1.el7.x86_64.rpm</a>                     17-Apr-2024 15:29            17037348
</pre><hr></body>
</html>
```
Все успешно , теперь можем прописать нашу репозиторию в /etc/yum.repos.d/

```
[ansible-local]
name=otus
baseurl=http://localhost/repo
enabled=1
gpgcheck=0
```
Теперь мы можем повторно установить наш ansible через репозиторию 

```
yum install ansible.x86_64 
```

![Установка ansible из репозитории](https://github.com/Dogmatic41/otus/blob/main/8.RPM/images/install%20ansible.png?raw=true)
![Проверка ansible из репозитории и версия утсановки](https://github.com/Dogmatic41/otus/blob/main/8.RPM/images/ansible%20version.png?raw=true)