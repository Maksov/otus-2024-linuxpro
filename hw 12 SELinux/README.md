## Домашее задание № 12 SELinux

### Занятие 18. SELinux

#### Цель

Диагностировать проблемы и модифицировать политики SELinux для корректной работы приложений, если это требуется.

#### Описание домашнего задания

1. Запустить nginx на нестандартном порту 3-мя разными способами:
- переключатели setsebool;
- добавление нестандартного порта в имеющийся тип;
- формирование и установка модуля SELinux.
К сдаче:
- README с описанием каждого решения (скриншоты и демонстрация приветствуются). 

2. Обеспечить работоспособность приложения при включенном selinux.
- развернуть приложенный стенд https://github.com/mbfx/otus-linux-adm/tree/master/selinux_dns_problems; 
- выяснить причину неработоспособности механизма обновления зоны (см. README);
- предложить решение (или решения) для данной проблемы;
- выбрать одно из решений для реализации, предварительно обосновав выбор;
- реализовать выбранное решение и продемонстрировать его работоспособность

#### Ход работы

0. Создаём виртуальную машину

Создаём каталог, в котором будут храниться настройки виртуальной машины. В каталоге создаём файл с именем Vagrantfile, добавляем в него содержимое согласно методичке.

Результатом выполнения команды vagrant up станет созданная виртуальная машина с установленным nginx, который работает на порту TCP 4881. Порт TCP 4881 уже проброшен до хоста. SELinux включен.

Во время развёртывания стенда попытка запустить nginx завершится с ошибкой:

![Рисунок](1.png)

#### 1. Запуск nginx на нестандартном порту 3-мя разными способами 

Выполним предварительные проверки согласно методичке:

![Рисунок](2.png)

##### Разрешим в SELinux работу nginx на порту TCP 4881 c помощью переключателей setsebool

Находим в логах (/var/log/audit/audit.log) информацию о блокировании порта

```
[root@selinux ~]# audit2why < /var/log/audit/audit.log
type=AVC msg=audit(1716176044.871:831): avc:  denied  { name_bind } for  pid=2847 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0

    Was caused by:
    The boolean nis_enabled was set incorrectly. 
    Description:
    Allow nis to enabled

    Allow access by executing:
    # setsebool -P nis_enabled 1

```

Включим параметр nis_enabled и перезапустим nginx: 

![Рисунок](3.png)

Вернём запрет работы nginx на порту 4881 обратно. Для этого отключим nis_enabled: setsebool -P nis_enabled off

##### Теперь разрешим в SELinux работу nginx на порту TCP 4881 c помощью добавления нестандартного порта в имеющийся тип:

Поиск имеющегося типа, для http трафика:

```
[root@selinux ~]# semanage port -l | grep http
http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
http_cache_port_t              udp      3130
http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
pegasus_https_port_t           tcp      5989
[root@selinux ~]# ^C

```

Добавим порт в тип http_port_t:

```

[root@selinux ~]# semanage port -a -t http_port_t -p tcp 4881
[root@selinux ~]# semanage port -l | grep http
http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
http_cache_port_t              udp      3130
http_port_t                    tcp      4881, 80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
pegasus_https_port_t           tcp      5989

```
Теперь перезапустим службу nginx и проверим её работу: systemctl restart nginx

```
[root@selinux ~]# systemctl restart nginx
[root@selinux ~]# systemctl st
start   status  stop    
[root@selinux ~]# systemctl st
start   status  stop    
[root@selinux ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Mon 2024-05-20 06:17:28 UTC; 16s ago
  Process: 21991 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 21989 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 21988 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 21993 (nginx)
   CGroup: /system.slice/nginx.service
           ├─21993 nginx: master process /usr/sbin/nginx
           └─21994 nginx: worker process

May 20 06:17:28 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
May 20 06:17:28 selinux nginx[21989]: nginx: the configuration file /etc/nginx/nginx.conf ... ok
May 20 06:17:28 selinux nginx[21989]: nginx: configuration file /etc/nginx/nginx.conf test...ful
May 20 06:17:28 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.
Hint: Some lines were ellipsized, use -l to show in full.

```

Удалить нестандартный порт из имеющегося типа можно с помощью команды: semanage port -d -t http_port_t -p tcp 4881

###### Разрешим в SELinux работу nginx на порту TCP 4881 c помощью формирования и установки модуля SELinux

Воспользуемся утилитой audit2allow для того, чтобы на основе логов SELinux сделать модуль, разрешающий работу nginx на нестандартном порту: 

```
[root@selinux ~]# grep nginx /var/log/audit/audit.log | audit2allow -M nginx
******************** IMPORTANT ***********************
To make this policy package active, execute:

semodule -i nginx.pp

[root@selinux ~]# semodule -i nginx.pp
[root@selinux ~]# 

```
Audit2allow сформировал модуль, и сообщил нам команду, с помощью которой можно применить данный модуль: semodule -i nginx.pp

Попробуем снова запустить nginx: 

```
[root@selinux ~]# systemctl restart nginx
[root@selinux ~]# systemctl status  nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Mon 2024-05-20 06:39:36 UTC; 3s ago
  Process: 22051 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 22049 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 22047 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 22053 (nginx)
   CGroup: /system.slice/nginx.service
           ├─22053 nginx: master process /usr/sbin/nginx
           └─22055 nginx: worker process

May 20 06:39:35 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
May 20 06:39:36 selinux nginx[22049]: nginx: the configuration file /etc/nginx/nginx.c... ok
May 20 06:39:36 selinux nginx[22049]: nginx: configuration file /etc/nginx/nginx.conf ...ful
May 20 06:39:36 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.
Hint: Some lines were ellipsized, use -l to show in full.

```
#### 2. Обеспечение работоспособности приложения при включенном SELinux

Развернём 2 ВМ ns01 и client с помощью vagrant: vagrant up
После того, как стенд развернется, проверим ВМ с помощью команды: vagrant status

```
[maksim@centos8 selinux_dns_problems]$ vagrant status
Current machine states:

ns01                      running (virtualbox)
client                    running (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
[maksim@centos8 selinux_dns_problems]$ 
```

Подключимся к клиенту: vagrant ssh client

```
[vagrant@client ~]$ dig @192.168.50.10 ns01.dns.lab

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.15 <<>> @192.168.50.10 ns01.dns.lab
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 28832
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;ns01.dns.lab.          IN  A

;; ANSWER SECTION:
ns01.dns.lab.       3600    IN  A   192.168.50.10

;; AUTHORITY SECTION:
dns.lab.        3600    IN  NS  ns01.dns.lab.

;; Query time: 4 msec
;; SERVER: 192.168.50.10#53(192.168.50.10)
;; WHEN: Mon May 20 11:52:30 UTC 2024
;; MSG SIZE  rcvd: 71

```

Попробуем внести изменения в зону: nsupdate -k /etc/named.zonetransfer.key

```
[vagrant@client ~]$ nsupdate -k /etc/named.zonetransfer.key
> server 192.168.50.10
> zone ddns.lab
> update add www.ddns.lab. 60 A 192.168.50.15
> send
update failed: SERVFAIL
> 
```

Изменения внести не получилось. Давайте посмотрим логи SELinux, чтобы понять в чём может быть проблема.

```
[root@ns01 ~]# cat /var/log/audit/audit.log | audit2why
type=AVC msg=audit(1716195578.320:1891): avc:  denied  { write } for  pid=5136 comm="isc-worker0000" name="named" dev="sda1" ino=67546138 scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:named_zone_t:s0 tclass=dir permissive=0

    Was caused by:
    The boolean named_write_master_zones was set incorrectly. 
    Description:
    Allow named to write master zones

    Allow access by executing:
    # setsebool -P named_write_master_zones 1
type=AVC msg=audit(1716206221.061:1939): avc:  denied  { create } for  pid=5136 comm="isc-worker0000" name="named.ddns.lab.view1.jnl" scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:etc_t:s0 tclass=file permissive=0

    Was caused by:
        Missing type enforcement (TE) allow rule.

        You can use audit2allow to generate a loadable module to allow this access.

```

В логах мы видим, что ошибка в контексте безопасности. Вместо типа named_t используется тип etc_t.
Проверим данную проблему в каталоге /etc/named:

```
[root@ns01 ~]# ls -laZ /etc/named
drw-rwx---. root named system_u:object_r:etc_t:s0       .
drwxr-xr-x. root root  system_u:object_r:etc_t:s0       ..
drw-rwx---. root named unconfined_u:object_r:etc_t:s0   dynamic
-rw-rw----. root named system_u:object_r:etc_t:s0       named.50.168.192.rev
-rw-rw----. root named system_u:object_r:etc_t:s0       named.dns.lab
-rw-rw----. root named system_u:object_r:etc_t:s0       named.dns.lab.view1
-rw-rw----. root named system_u:object_r:etc_t:s0       named.newdns.lab

```

также видим, что контекст безопасности неправильный. Проблема заключается в том, что конфигурационные файлы лежат в другом каталоге. Посмотреть в каком каталоги должны лежать, файлы, чтобы на них распространялись правильные политики SELinux можно с помощью команды: sudo semanage fcontext -l | grep named

```
[root@ns01 ~]# sudo semanage fcontext -l | grep named
/etc/rndc.*                                        regular file       system_u:object_r:named_conf_t:s0 
/var/named(/.*)?                                   all files          system_u:object_r:named_zone_t:s0 
/etc/unbound(/.*)?                                 all files          system_u:object_r:named_conf_t:s0 
/var/run/bind(/.*)?                                all files          system_u:object_r:named_var_run_t:s0 
/var/log/named.*                                   regular file       system_u:o
```

Изменим тип контекста безопасности для каталога /etc/named: sudo chcon -R -t named_zone_t /etc/named
```
[root@ns01 ~]# sudo chcon -R -t named_zone_t /etc/named
[root@ns01 ~]# ls -laZ /etc/named
drw-rwx---. root named system_u:object_r:named_zone_t:s0 .
drwxr-xr-x. root root  system_u:object_r:etc_t:s0       ..
drw-rwx---. root named unconfined_u:object_r:named_zone_t:s0 dynamic
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.50.168.192.rev
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.dns.lab
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.dns.lab.view1
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.newdns.lab
[root@ns01 ~]# 
```
Попробуем снова внести изменения с клиента: 
```
[vagrant@client ~]$ dig www.ddns.lab

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.15 <<>> www.ddns.lab
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 62631
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www.ddns.lab.          IN  A

;; ANSWER SECTION:
www.ddns.lab.       60  IN  A   192.168.50.15

;; AUTHORITY SECTION:
ddns.lab.       3600    IN  NS  ns01.dns.lab.

;; ADDITIONAL SECTION:
ns01.dns.lab.       3600    IN  A   192.168.50.10

;; Query time: 101 msec
;; SERVER: 192.168.50.10#53(192.168.50.10)
;; WHEN: Mon May 20 16:07:35 UTC 2024
;; MSG SIZE  rcvd: 96

[vagrant@client ~]$ 
```
Все работает.

