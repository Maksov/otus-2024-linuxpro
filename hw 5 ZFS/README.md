## Домашее задание № 5 ZFS

### Занятие 8. ZFS

#### Цель

Научится самостоятельно устанавливать ZFS, настраивать пулы, изучить основные возможности ZFS. 

#### Описание домашнего задания

1. Определить алгоритм с наилучшим сжатием:
- Определить какие алгоритмы сжатия поддерживает zfs (gzip, zle, lzjb, lz4);
- создать 4 файловых системы на каждой применить свой алгоритм сжатия;
- для сжатия использовать либо текстовый файл, либо группу файлов.
2. Определить настройки пула.
С помощью команды zfs import собрать pool ZFS.
Командами zfs определить настройки:
    - размер хранилища;
    - тип pool;
    - значение recordsize;
    - какое сжатие используется;
    - какая контрольная сумма используется.
3. Работа со снапшотами:
- скопировать файл из удаленной директории;
- восстановить файл локально. zfs receive;
- найти зашифрованное сообщение в файле secret_message.

#### Ход работы

1. Определение алгоритма с наилучшим сжатием

Смотри список всех дисков

```
[root@localhost ~]# lsblk 
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   40G  0 disk 
`-sda1   8:1    0   40G  0 part /
sdb      8:16   0  512M  0 disk 
sdc      8:32   0  512M  0 disk 
sdd      8:48   0  512M  0 disk 
sde      8:64   0  512M  0 disk 
sdf      8:80   0  512M  0 disk 
sdg      8:96   0  512M  0 disk 
sdh      8:112  0  512M  0 disk 
sdi      8:128  0  512M  0 disk 
[root@localhost ~]# 

```
Создаем пулы дисков с зеркалированием

```
[root@localhost ~]# zpool create maksdisk1 mirror /dev/sdb /dev/sdc
[root@localhost ~]# zpool create maksdisk2 mirror /dev/sdd /dev/sde
[root@localhost ~]# zpool create maksdisk3 mirror /dev/sdf /dev/sdg
[root@localhost ~]# zpool create maksdisk4 mirror /dev/sdh /dev/sdi
```
Информация о пулах
```
[root@localhost ~]# zpool list
NAME        SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
maksdisk1   480M   106K   480M        -         -     0%     0%  1.00x    ONLINE  -
maksdisk2   480M  91.5K   480M        -         -     0%     0%  1.00x    ONLINE  -
maksdisk3   480M  91.5K   480M        -         -     0%     0%  1.00x    ONLINE  -
maksdisk4   480M  91.5K   480M        -         -     0%     0%  1.00x    ONLINE  -
[root@localhost ~]# 

```
Добавим разные алгоритмы сжатия в каждую файловую систему:
Алгоритм lzjb: zfs set compression=lzjb maksdisk1
Алгоритм lz4:  zfs set compression=lz4 maksdisk2
Алгоритм gzip: zfs set compression=gzip-9 maksdisk3
Алгоритм zle:  zfs set compression=zle maksdisk4

Проверка методов сжатия
```
[root@localhost ~]# zfs get all | grep compression
maksdisk1  compression           lzjb                   local
maksdisk2  compression           lz4                    local
maksdisk3  compression           gzip-9                 local
maksdisk4  compression           zle                    local
[root@localhost ~]# 
```

Проверим, сколько места занимает один и тот же файл в разных пулах и проверим степень сжатия файлов:
```
[root@localhost ~]# zfs list
NAME        USED  AVAIL     REFER  MOUNTPOINT
maksdisk1  21.7M   330M     21.6M  /maksdisk1
maksdisk2  17.7M   334M     17.6M  /maksdisk2
maksdisk3  10.8M   341M     10.7M  /maksdisk3
maksdisk4  39.3M   313M     39.2M  /maksdisk4
[root@localhost ~]# zfs get all | grep compressratio | grep -v ref
maksdisk1  compressratio         1.81x                  -
maksdisk2  compressratio         2.22x                  -
maksdisk3  compressratio         3.65x                  -
maksdisk4  compressratio         1.00x                  -
[root@localhost ~]# 
```
Самый эффективный алгоритм сжатия - gzip-9

2. Определение настроек пула
Скачиваем архив и разархивируем его

Импортируем каталог в пул: 
```

[root@localhost ~]# zpool import -d zpoolexport/
   pool: otus
     id: 6554193320433390805
  state: ONLINE
 action: The pool can be imported using its name or numeric identifier.
 config:

	otus                         ONLINE
	  mirror-0                   ONLINE
	    /root/zpoolexport/filea  ONLINE
	    /root/zpoolexport/fileb  ONLINE
[root@localhost ~]# 
```

Выполним импорт данного пул в ОС:

```
[root@localhost ~]# zpool import -d zpoolexport/ otus
[root@localhost ~]# zpool status
  pool: maksdisk1
 state: ONLINE
  scan: none requested
config:

	NAME        STATE     READ WRITE CKSUM
	maksdisk1   ONLINE       0     0     0
	  mirror-0  ONLINE       0     0     0
	    sdb     ONLINE       0     0     0
	    sdc     ONLINE       0     0     0

errors: No known data errors

  pool: maksdisk2
 state: ONLINE
  scan: none requested
config:

	NAME        STATE     READ WRITE CKSUM
	maksdisk2   ONLINE       0     0     0
	  mirror-0  ONLINE       0     0     0
	    sdd     ONLINE       0     0     0
	    sde     ONLINE       0     0     0

errors: No known data errors

  pool: maksdisk3
 state: ONLINE
  scan: none requested
config:

	NAME        STATE     READ WRITE CKSUM
	maksdisk3   ONLINE       0     0     0
	  mirror-0  ONLINE       0     0     0
	    sdf     ONLINE       0     0     0
	    sdg     ONLINE       0     0     0

errors: No known data errors

  pool: maksdisk4
 state: ONLINE
  scan: none requested
config:

	NAME        STATE     READ WRITE CKSUM
	maksdisk4   ONLINE       0     0     0
	  mirror-0  ONLINE       0     0     0
	    sdh     ONLINE       0     0     0
	    sdi     ONLINE       0     0     0

errors: No known data errors

  pool: otus
 state: ONLINE
  scan: none requested
config:

	NAME                         STATE     READ WRITE CKSUM
	otus                         ONLINE       0     0     0
	  mirror-0                   ONLINE       0     0     0
	    /root/zpoolexport/filea  ONLINE       0     0     0
	    /root/zpoolexport/fileb  ONLINE       0     0     0

errors: No known data errors
[root@localhost ~]# 


```
Определим настройки пула: zpool get all otus

```
[root@localhost ~]# zfs get all otus
NAME  PROPERTY              VALUE                  SOURCE
otus  type                  filesystem             -
otus  creation              Fri May 15  4:00 2020  -
otus  used                  2.04M                  -
otus  available             350M                   -
otus  referenced            24K                    -
otus  compressratio         1.00x                  -
otus  mounted               yes                    -
otus  quota                 none                   default
otus  reservation           none                   default
otus  recordsize            128K                   local
otus  mountpoint            /otus                  default
otus  sharenfs              off                    default
otus  checksum              sha256                 local
otus  compression           zle                    local
otus  atime                 on                     default
otus  devices               on                     default
otus  exec                  on                     default
otus  setuid                on                     default
otus  readonly              off                    default
otus  zoned                 off                    default
otus  snapdir               hidden                 default
otus  aclinherit            restricted             default
otus  createtxg             1                      -
otus  canmount              on                     default
otus  xattr                 on                     default
otus  copies                1                      default
otus  version               5                      -
otus  utf8only              off                    -
otus  normalization         none                   -
otus  casesensitivity       sensitive              -
otus  vscan                 off                    default
otus  nbmand                off                    default
otus  sharesmb              off                    default
otus  refquota              none                   default
otus  refreservation        none                   default
otus  guid                  14592242904030363272   -
otus  primarycache          all                    default
otus  secondarycache        all                    default
otus  usedbysnapshots       0B                     -
otus  usedbydataset         24K                    -
otus  usedbychildren        2.01M                  -
otus  usedbyrefreservation  0B                     -
otus  logbias               latency                default
otus  objsetid              54                     -
otus  dedup                 off                    default
otus  mlslabel              none                   default
otus  sync                  standard               default
otus  dnodesize             legacy                 default
otus  refcompressratio      1.00x                  -
otus  written               24K                    -
otus  logicalused           1020K                  -
otus  logicalreferenced     12K                    -
otus  volmode               default                default
otus  filesystem_limit      none                   default
otus  snapshot_limit        none                   default
otus  filesystem_count      none                   default
otus  snapshot_count        none                   default
otus  snapdev               hidden                 default
otus  acltype               off                    default
otus  context               none                   default
otus  fscontext             none                   default
otus  defcontext            none                   default
otus  rootcontext           none                   default
otus  relatime              off                    default
otus  redundant_metadata    all                    default
otus  overlay               off                    default
otus  encryption            off                    default
otus  keylocation           none                   default
otus  keyformat             none                   default
otus  pbkdf2iters           0                      default
otus  special_small_blocks  0                      default
[root@localhost ~]# 

```
3. Работа со снапшотом, поиск сообщения от преподавателя

Скачаем файл и восстановим файловую систему из снапшота:
```
[root@localhost ~]# zfs receive otus/test@today < otus_task2.file
[root@localhost ~]# find /otus/test -name "secret_message"
/otus/test/task1/file_mess/secret_message
[root@localhost ~]# cat /otus/test/task1/file_mess/secret_message
https://otus.ru/lessons/linux-hl/

[root@localhost ~]# 

```