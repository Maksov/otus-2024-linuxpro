## Домашее задание № 6 Управление пакетами

### Занятие 8. Управление пакетами. Дистрибьюция софта

#### Описание домашнего задания

Домашнее задание

1) Создать свой RPM пакет 
2) Создать свой репозиторий и разместить там ранее собранный RPM

Репозиторий для проверки доступен по адресу http://158.160.158.58/repo/
#### Ход работы

##### Установка пакетов для сборки пакетов

```
sudo yum install -y redhat-lsb-core \wget rpmdevtools rpm-build createrepo yum-utils gcc
Failed to set locale, defaulting to C.UTF-8
CentOS Stream 8 - AppStream                      13 kB/s | 4.4 kB     00:00    
CentOS Stream 8 - AppStream                     8.8 MB/s |  28 MB     00:03    
CentOS Stream 8 - BaseOS                         31 kB/s | 3.9 kB     00:00    
CentOS Stream 8 - BaseOS                         23 MB/s |  10 MB     00:00    
CentOS Stream 8 - Extras                        7.3 kB/s | 2.9 kB     00:00    
CentOS Stream 8 - Extras common packages        7.7 kB/s | 3.0 kB     00:00    
CentOS Stream 8 - Extras common packages         15 kB/s | 7.7 kB     00:00    
Package yum-utils-4.0.21-25.el8.noarch is already installed.
Dependencies resolved.
================================================================================
 Package                Arch   Version                          Repo       Size
================================================================================
Installing:
 createrepo_c           x86_64 0.17.7-6.el8                     appstream  89 k
 gcc                    x86_64 8.5.0-21.el8                     baseos     23 M
 redhat-lsb-core        x86_64 4.1-47.el8                       appstream  46 k
 rpm-build              x86_64 4.14.3-31.el8                    appstream 185 k
 rpmdevtools            noarch 8.10-8.el8                       appstream  87 k
 wget                   x86_64 1.19.5-11.el8                    appstream 734 k
Installing dependencies:
 annobin                x86_64 11.13-2.el8                      baseos    972 k
 at                     x86_64 3.1.20-12.el8                    baseos     81 k
 avahi-libs             x86_64 0.7-27.el8                       baseos     62 k
 bc                     x86_64 1.07.1-5.el8                     baseos    129 k
 binutils               x86_64 2.30-123.el8                     baseos    5.8 M
 bzip2                  x86_64 1.0.6-26.el8                     baseos     60 k
 cpp                    x86_64 8.5.0-21.el8                     baseos     10 M
 ...
```
Возьмем пакет NGINX и соберем его с поддержкой openssl

● Загрузим SRPM пакет NGINX для дальнейшей работы над ним:
[root@otus-hw6 admin]#
wget https://nginx.org/packages/centos/8/SRPMS/nginx-1.20.2-1.el8.ngx.src.rpm

● При установке такого пакета в домашней директории создается древо каталогов для
сборки:
[root@otus-hw6 admin]# rpm -i nginx-1.*

Также нужно скачать и разархивировать последний исходник для openssl - он
потребуется при сборке
[root@otus-hw6 admin]# wget https://www.openssl.org/source/old/1.1.1/openssl-1.1.1w.tar.gz
[root@otus-hw6 admin]# tar -xvf openssl*.tar.gz
● Ставим зависимости NGINX
[root@otus-hw6 ~]# yum-builddep rpmbuild/SPECS/nginx.spec
```
Last metadata expiration check: 2:07:33 ago on Sun Apr  7 11:14:05 2024.
Package systemd-239-82.el8.x86_64 is already installed.
Dependencies resolved.
================================================================================
 Package                  Arch        Version                 Repository   Size
================================================================================
Installing:
 openssl-devel            x86_64      1:1.1.1k-12.el8         baseos      3.2 M
 pcre-devel               x86_64      8.42-6.el8              baseos      551 k
 zlib-devel               x86_64      1.2.11-25.el8           baseos       59 k

```

● Корректируем spec файл для сборки NGINX с необходимыми нам опциями:
```
--with-openssl=/root/openssl-1.1.1w
```

● Собираем RPM пакет:
```
[root@otus-hw6 ~]# rpmbuild -bb rpmbuild/SPECS/nginx.spec

Executing(%prep): /bin/sh -e /var/tmp/rpm-tmp.sDvrYx
+ umask 022
+ cd /root/rpmbuild/BUILD
+ cd /root/rpmbuild/BUILD
+ rm -rf nginx-1.20.2
+ /usr/bin/gzip -dc /root/rpmbuild/SOURCES/nginx-1.20.2.tar.gz
+ /usr/bin/tar -xof -
+ STATUS=0
...
Creating Makefile

**********************************************************************
***                                                                ***
***   OpenSSL has been successfully configured                     ***
***                                                                ***
***   If you encounter a problem while building, please open an    ***
***   issue on GitHub <https://github.com/openssl/openssl/issues>  ***
***   and include the output from the following command:           ***
***                                                                ***
***       perl configdata.pm --dump                                ***
***                                                                ***
***   (If you are new to OpenSSL, you might want to consult the    ***
***   'Troubleshooting' section in the INSTALL file first)         ***
***                                                                ***
**********************************************************************
make[2]: Entering directory '/root/openssl-1.1.1w'
....
Executing(%clean): /bin/sh -e /var/tmp/rpm-tmp.5qDQ0n
+ umask 022
+ cd /root/rpmbuild/BUILD
+ cd nginx-1.20.2
+ /usr/bin/rm -rf /root/rpmbuild/BUILDROOT/nginx-1.20.2-1.el8.ngx.x86_64
+ exit 0

```
● Убедимся, что пакеты создались:
[root@packages ~]# ll rpmbuild/RPMS/x86_64/
```
[root@otus-hw6 ~]# ll rpmbuild/RPMS/x86_64/
total 4456
-rw-r--r--. 1 root root 2060664 Apr  7 13:41 nginx-1.20.2-1.el8.ngx.x86_64.rpm
-rw-r--r--. 1 root root 2495892 Apr  7 13:41 nginx-debuginfo-1.20.2-1.el8.ngx.x86_64.rpm

```
● Установим пакет
```
[root@otus-hw6 ~]# yum localinstall -y rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el8.ngx.x86_64.rpm 

...
Installed:
  nginx-1:1.20.2-1.el8.ngx.x86_64                                               

Complete!
```

● Запустим nginx
```
[root@otus-hw6 ~]# systemctl start nginx
[root@otus-hw6 ~]# systemctl status nginx
● nginx.service - nginx - high performance web server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor pres>
   Active: active (running) since Sun 2024-04-07 13:46:04 UTC; 7s ago
```

##### Создание репозитория и размещение там собранного RPM

```
[root@otus-hw6 ~]#  mkdir /usr/share/nginx/html/repo

```

● Копируем туда наш собранный RPM и RPM для установки репозитория Percona-Server.

● Инициализируем репозиторий командой:

```
[root@otus-hw6 ~]# createrepo /usr/share/nginx/html/repo/
Directory walk started
Directory walk done - 2 packages
Temporary output repo path: /usr/share/nginx/html/repo/.repodata/
Preparing sqlite DBs
Pool started (with 5 workers)
Pool finished
```
● Для прозрачности настроим в NGINX доступ к листингу каталога:

```
location / {
root /usr/share/nginx/html;
index index.html index.htm;
autoindex on; < Добавили эту директиву
}


```
● Добавим репозиторий в /etc/yum.repos.d
```
[root@otus-hw6 ~]# cat /etc/yum.repos.d/otus.repo
[otus]
name=otus-maksov-hw6
baseurl=http://158.160.158.58/repo/
gpgcheck=0
enabled=1

[root@otus-hw6 ~]# yum repolist enabled | grep otus
Failed to set locale, defaulting to C.UTF-8
otus                       otus-maksov-hw6
[root@otus-hw6 ~]# yum list | grep otus
Failed to set locale, defaulting to C.UTF-8
otus-maksov-hw6                                 165 kB/s | 2.8 kB     00:00    
percona-orchestrator.x86_64                            2:3.2.6-2.el8                                         otus         

Почему-то не показывает nginx. С другой системы проверил- показывает. А там где стоит не хочет показывать. Хотя роде на репу должен ссылаться @maksov
```

● Так как NGINX у нас уже стоит, установим репозиторий percona-release:
```
[root@otus-hw6 ~]# yum install percona-orchestrator.x86_64 -y

Installed:
  jq-1.6-8.el8.x86_64      oniguruma-6.8.2-3.el8.x86_64      percona-orchestrator-2:3.2.6-2.el8.x86_64     

Complete!
```
