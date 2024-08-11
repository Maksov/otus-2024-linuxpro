## Домашее задание № 23 DNS

### Занятие 36. DNS- настройка и обслуживание

#### Цель

Создать домашнюю сетевую лабораторию. Изучить основы DNS, научиться работать с технологией Split-DNS в Linux-based системах

#### Описание домашнего задания

1. взять стенд https://github.com/erlong15/vagrant-bind 
добавить еще один сервер client2
завести в зоне dns.lab имена:
web1 - смотрит на клиент1
web2  смотрит на клиент2
завести еще одну зону newdns.lab
завести в ней запись
www - смотрит на обоих клиентов

2. настроить split-dns
клиент1 - видит обе зоны, но в зоне dns.lab только web1
клиент2 видит только dns.lab

Дополнительное задание
* настроить все без выключения selinux

#### Ход работы

1. Работа со стендом и настройка DNS

Скачаем себе стенд https://github.com/erlong15/vagrant-bind, перейдём в скаченный каталог и изучим содержимое файлов:

```
➜  git clone https://github.com/erlong15/vagrant-bind.git
➜  cd vagrant-bind 
➜  vagrant-bind  ls -l 
total 12
drwxrwxr-x 2 alex alex 4096 мар 22 18:03 provisioning
-rw-rw-r-- 1 alex alex  414 мар 22 18:03 README.md
-rw-rw-r-- 1 alex alex  820 мар 22 18:03 Vagrantfile
```

Мы увидем файл Vagrantfile. Откроем его в любом, удобном для вас текстовом редакторе и добавим необходимую ВМ:
```
 config.vm.define "client2" do |client2|
    client2.vm.network "private_network", ip: "192.168.50.16", virtualbox__intnet: "dns"
    client2.vm.hostname = "client2"
  end

```

2. Работа с Ansible

Ansible файлы приводятся в соответствии с методическими рекомендациями.

3. Настройка Split-DNS



