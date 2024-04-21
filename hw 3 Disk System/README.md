## Домашее задание № 3 Дисковая подсистема

### Занятие 3. Работа с mdadm

#### Описание домашнего задания
• добавить в Vagrantfile еще дисков

• собрать R0/R5/R10 на выбор

• прописать собранный рейд в конф, чтобы рейд собирался при загрузке

• сломать/починить raid 

• создать GPT раздел и 5 партиций и смонтировать их на диск.

В качестве проверки принимается - измененный Vagrantfile, скрипт для создания рейда, конф для автосборки рейда при загрузке.

* Доп. задание - Vagrantfile, который сразу собирает систему с подключенным рейдом

1. Настроено рабочее окружение
	- Windows 10
	- VMware Workstation Pro
	- Vagrant
	- Vagrant-Vmware-Utility
	
2. Порядок выполнения задания
В конфигурационном файле изменена логика создания и присоединения дисков к ВМ для VMware*
*было непросто сообразить логику
Добавлен доп диск для сбора RAID
```
C:\Users\Maksim\Documents\GitHub\otus-2024-linuxpro\hw 3 Disk System>vagrant up
Bringing machine 'otuslinux' up with 'vmware_workstation' provider...
==> otuslinux: Cloning VMware VM: 'centos/7'. This can take some time...
==> otuslinux: Checking if box 'centos/7' version '2004.01' is up to date...
==> otuslinux: There was a problem while downloading the metadata for your box
==> otuslinux: to check for updates. This is not an error, since it is usually due
==> otuslinux: to temporary network problems. This is just a warning. The problem
==> otuslinux: encountered was:
==> otuslinux:
==> otuslinux: The requested URL returned error: 404
==> otuslinux:
==> otuslinux: If you want to check for box updates, verify your network connection
==> otuslinux: is valid and try again.
==> otuslinux: Verifying vmnet devices are healthy...
==> otuslinux: Preparing network adapters...
WARNING: The VMX file for this box contains a setting that is automatically overwritten by Vagrant
WARNING: when started. Vagrant will stop overwriting this setting in an upcoming release which may
WARNING: prevent proper networking setup. Below is the detected VMX setting:
WARNING:
WARNING:   ethernet0.pcislotnumber = "32"
WARNING:
WARNING: If networking fails to properly configure, it may require this VMX setting. It can be manually
WARNING: applied via the Vagrantfile:
WARNING:
WARNING:   Vagrant.configure(2) do |config|
WARNING:     config.vm.provider :vmware_desktop do |vmware|
WARNING:       vmware.vmx["ethernet0.pcislotnumber"] = "32"
WARNING:     end
WARNING:   end
WARNING:
WARNING: For more information: https://www.vagrantup.com/docs/vmware/boxes.html#vmx-allowlisting
==> otuslinux: Fixed port collision for 22 => 2222. Now on port 2200.
==> otuslinux: Starting the VMware VM...
==> otuslinux: Waiting for the VM to receive an address...
==> otuslinux: Forwarding ports...
    otuslinux: -- 22 => 2200
==> otuslinux: Waiting for machine to boot. This may take a few minutes...
    otuslinux: SSH address: 127.0.0.1:2200
    otuslinux: SSH username: vagrant
    otuslinux: SSH auth method: private key
    otuslinux:
    otuslinux: Vagrant insecure key detected. Vagrant will automatically replace
    otuslinux: this with a newly generated keypair for better security.
    otuslinux:
    otuslinux: Inserting generated public key within guest...
    otuslinux: Removing insecure key from the guest if it's present...
    otuslinux: Key inserted! Disconnecting and reconnecting using new SSH key...
==> otuslinux: Machine booted and ready!
==> otuslinux: Setting hostname...
==> otuslinux: Configuring network adapters within the VM...
==> otuslinux: Rsyncing folder: /cygdrive/c/Users/Maksim/Documents/GitHub/otus-2024-linuxpro/hw 3 Disk System/ => /vagrant
==> otuslinux: Running provisioner: shell...
    otuslinux: Running: inline script
    otuslinux: Loaded plugins: fastestmirror
    otuslinux: Determining fastest mirrors
    otuslinux:  * base: mirror.corbina.net
    otuslinux:  * extras: mirror.corbina.net
    otuslinux:  * updates: mirror.yandex.ru
    otuslinux: Resolving Dependencies
    otuslinux: --> Running transaction check
    otuslinux: ---> Package gdisk.x86_64 0:0.8.10-3.el7 will be installed
    otuslinux: ---> Package hdparm.x86_64 0:9.43-5.el7 will be installed
    otuslinux: ---> Package mdadm.x86_64 0:4.1-9.el7_9 will be installed
    otuslinux: --> Processing Dependency: libreport-filesystem for package: mdadm-4.1-9.el7_9.x86_64
    otuslinux: ---> Package smartmontools.x86_64 1:7.0-2.el7 will be installed
    otuslinux: --> Processing Dependency: mailx for package: 1:smartmontools-7.0-2.el7.x86_64
    otuslinux: --> Running transaction check
    otuslinux: ---> Package libreport-filesystem.x86_64 0:2.1.11-53.el7.centos will be installed
    otuslinux: ---> Package mailx.x86_64 0:12.5-19.el7 will be installed
    otuslinux: --> Finished Dependency Resolution
    otuslinux:
    otuslinux: Dependencies Resolved
    otuslinux:
    otuslinux: ================================================================================
    otuslinux:  Package                  Arch       Version                  Repository   Size
    otuslinux: ================================================================================
    otuslinux: Installing:
    otuslinux:  gdisk                    x86_64     0.8.10-3.el7             base        190 k
    otuslinux:  hdparm                   x86_64     9.43-5.el7               base         83 k
    otuslinux:  mdadm                    x86_64     4.1-9.el7_9              updates     439 k
    otuslinux:  smartmontools            x86_64     1:7.0-2.el7              base        546 k
    otuslinux: Installing for dependencies:
    otuslinux:  libreport-filesystem     x86_64     2.1.11-53.el7.centos     base         41 k
    otuslinux:  mailx                    x86_64     12.5-19.el7              base        245 k
    otuslinux:
    otuslinux: Transaction Summary
    otuslinux: ================================================================================
    otuslinux: Install  4 Packages (+2 Dependent packages)
    otuslinux:
    otuslinux: Total download size: 1.5 M
    otuslinux: Installed size: 4.3 M
    otuslinux: Downloading packages:
    otuslinux: Public key for hdparm-9.43-5.el7.x86_64.rpm is not installed
    otuslinux: warning: /var/cache/yum/x86_64/7/base/packages/hdparm-9.43-5.el7.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY
    otuslinux: Public key for mdadm-4.1-9.el7_9.x86_64.rpm is not installed
    otuslinux: --------------------------------------------------------------------------------
    otuslinux: Total                                              1.4 MB/s | 1.5 MB  00:01
    otuslinux: Retrieving key from file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
    otuslinux: Importing GPG key 0xF4A80EB5:
    otuslinux:  Userid     : "CentOS-7 Key (CentOS 7 Official Signing Key) <security@centos.org>"
    otuslinux:  Fingerprint: 6341 ab27 53d7 8a78 a7c2 7bb1 24c6 a8a7 f4a8 0eb5
    otuslinux:  Package    : centos-release-7-8.2003.0.el7.centos.x86_64 (@anaconda)
    otuslinux:  From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
    otuslinux: Running transaction check
    otuslinux: Running transaction test
    otuslinux: Transaction test succeeded
    otuslinux: Running transaction
    otuslinux:   Installing : libreport-filesystem-2.1.11-53.el7.centos.x86_64             1/6
    otuslinux:   Installing : mailx-12.5-19.el7.x86_64                                     2/6
    otuslinux:   Installing : 1:smartmontools-7.0-2.el7.x86_64                             3/6
    otuslinux:   Installing : mdadm-4.1-9.el7_9.x86_64                                     4/6
    otuslinux:   Installing : hdparm-9.43-5.el7.x86_64                                     5/6
    otuslinux:   Installing : gdisk-0.8.10-3.el7.x86_64                                    6/6
    otuslinux:   Verifying  : mdadm-4.1-9.el7_9.x86_64                                     1/6
    otuslinux:   Verifying  : 1:smartmontools-7.0-2.el7.x86_64                             2/6
    otuslinux:   Verifying  : gdisk-0.8.10-3.el7.x86_64                                    3/6
    otuslinux:   Verifying  : mailx-12.5-19.el7.x86_64                                     4/6
    otuslinux:   Verifying  : hdparm-9.43-5.el7.x86_64                                     5/6
    otuslinux:   Verifying  : libreport-filesystem-2.1.11-53.el7.centos.x86_64             6/6
    otuslinux:
    otuslinux: Installed:
    otuslinux:   gdisk.x86_64 0:0.8.10-3.el7          hdparm.x86_64 0:9.43-5.el7
    otuslinux:   mdadm.x86_64 0:4.1-9.el7_9           smartmontools.x86_64 1:7.0-2.el7
    otuslinux:
    otuslinux: Dependency Installed:
    otuslinux:   libreport-filesystem.x86_64 0:2.1.11-53.el7.centos mailx.x86_64 0:12.5-19.el7
    otuslinux:
    otuslinux: Complete!
```

- смотрим информацию о дисках
```
[vagrant@otuslinux ~]$ sudo lshw -short | grep disk
/0/100/15/0/0.0.0    /dev/sda   disk           42GB VMware Virtual S
/0/100/15/0/0.1.0    /dev/sdb   disk           21GB VMware Virtual S
/0/100/15/0/0.2.0    /dev/sdc   disk           21GB VMware Virtual S
/0/100/15/0/0.3.0    /dev/sdd   disk           21GB VMware Virtual S
/0/100/15/0/0.4.0    /dev/sde   disk           21GB VMware Virtual S
/0/100/15/0/0.5.0    /dev/sdf   disk           21GB VMware Virtual S

[vagrant@otuslinux ~]$ sudo fdisk -l

Disk /dev/sdf: 21.5 GB, 21474836480 bytes, 41943040 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sde: 21.5 GB, 21474836480 bytes, 41943040 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
....

```

- собираем RAID5
```
[vagrant@otuslinux ~]$ sudo mdadm --create --verbose /dev/md0 -l 5 -n 5 /dev/sd{b,c,d,e,f}
mdadm: layout defaults to left-symmetric
mdadm: layout defaults to left-symmetric
mdadm: chunk size defaults to 512K
mdadm: size set to 20954112K
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.

[vagrant@otuslinux ~]$ cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4]
md0 : active raid5 sdf[5] sde[3] sdd[2] sdc[1] sdb[0]
      83816448 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/4] [UUUU_]
      [========>............]  recovery = 41.2% (8640640/20954112) finish=1.0min speed=197160K/sec

unused devices: <none>

[vagrant@otuslinux ~]$ cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4]
md0 : active raid5 sdf[5] sde[3] sdd[2] sdc[1] sdb[0]
      83816448 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/5] [UUUUU]

unused devices: <none>

[vagrant@otuslinux ~]$ sudo mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Wed Mar 20 16:18:55 2024
        Raid Level : raid5
        Array Size : 83816448 (79.93 GiB 85.83 GB)
     Used Dev Size : 20954112 (19.98 GiB 21.46 GB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Wed Mar 20 16:20:42 2024
             State : clean
    Active Devices : 5
   Working Devices : 5
    Failed Devices : 0
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : otuslinux:0  (local to host otuslinux)
              UUID : a36b274d:b23dda44:0746f779:5342a6b5
            Events : 18

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       2       8       48        2      active sync   /dev/sdd
       3       8       64        3      active sync   /dev/sde
       5       8       80        4      active sync   /dev/sdf

```
- создаем конфигурационный файл mdadm.conf
```
[vagrant@otuslinux ~]$ sudo mdadm --detail --scan --verbose
ARRAY /dev/md0 level=raid5 num-devices=5 metadata=1.2 name=otuslinux:0 UUID=a36b274d:b23dda44:0746f779:5342a6b5
   devices=/dev/sdb,/dev/sdc,/dev/sdd,/dev/sde,/dev/sdf
   
[vagrant@otuslinux mdadm]$ cat /etc/mdadm/mdadm.conf
DEVICE partitions
ARRAY /dev/md0 level=raid5 num-devices=5 metadata=1.2 name=otuslinux:0 UUID=a36b274d:b23dda44:0746f779:5342a6b5
```
- сломаем и восстановим raid 

```
[vagrant@otuslinux mdadm]$ sudo mdadm /dev/md0 --fail /dev/sdc
mdadm: set /dev/sdc faulty in /dev/md0

[vagrant@otuslinux mdadm]$ cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4]
md0 : active raid5 sdf[5] sde[3] sdd[2] sdc[1](F) sdb[0]
      83816448 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/4] [U_UUU]

unused devices: <none>

[vagrant@otuslinux mdadm]$ sudo mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Wed Mar 20 16:18:55 2024
        Raid Level : raid5
        Array Size : 83816448 (79.93 GiB 85.83 GB)
     Used Dev Size : 20954112 (19.98 GiB 21.46 GB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Wed Mar 20 16:35:42 2024
             State : clean, degraded
    Active Devices : 4
   Working Devices : 4
    Failed Devices : 1
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : otuslinux:0  (local to host otuslinux)
              UUID : a36b274d:b23dda44:0746f779:5342a6b5
            Events : 20

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       -       0        0        1      removed
       2       8       48        2      active sync   /dev/sdd
       3       8       64        3      active sync   /dev/sde
       5       8       80        4      active sync   /dev/sdf

       1       8       32        -      faulty   /dev/sdc
	   
[vagrant@otuslinux mdadm]$ sudo mdadm /dev/md0 --remove /dev/sdc
mdadm: hot removed /dev/sdc from /dev/md0

[vagrant@otuslinux mdadm]$ sudo mdadm /dev/md0 --add /dev/sdc
mdadm: added /dev/sdc

[vagrant@otuslinux mdadm]$ cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4]
md0 : active raid5 sdc[6] sdf[5] sde[3] sdd[2] sdb[0]
      83816448 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/4] [U_UUU]
      [====>................]  recovery = 23.7% (4976384/20954112) finish=1.2min speed=207349K/sec

unused devices: <none>

[vagrant@otuslinux mdadm]$ sudo mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Wed Mar 20 16:18:55 2024
        Raid Level : raid5
        Array Size : 83816448 (79.93 GiB 85.83 GB)
     Used Dev Size : 20954112 (19.98 GiB 21.46 GB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Wed Mar 20 16:40:41 2024
             State : clean, degraded, recovering
    Active Devices : 4
   Working Devices : 5
    Failed Devices : 0
     Spare Devices : 1

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

    Rebuild Status : 66% complete

              Name : otuslinux:0  (local to host otuslinux)
              UUID : a36b274d:b23dda44:0746f779:5342a6b5
            Events : 33

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       6       8       32        1      spare rebuilding   /dev/sdc
       2       8       48        2      active sync   /dev/sdd
       3       8       64        3      active sync   /dev/sde
       5       8       80        4      active sync   /dev/sdf
```

- Создать GPT раздел, пять партиций и смонтировать их на диск
```
[vagrant@otuslinux mdadm]$ sudo parted -s /dev/md0 mklabel gpt
[vagrant@otuslinux mdadm]$ sudo parted /dev/md0 mkpart primary ext4 0% 20%
Information: You may need to update /etc/fstab.

[vagrant@otuslinux mdadm]$ sudo parted /dev/md0 mkpart primary ext4 20% 40%
Information: You may need to update /etc/fstab.

[vagrant@otuslinux mdadm]$ sudo parted /dev/md0 mkpart primary ext4 40% 60%
Information: You may need to update /etc/fstab.

[vagrant@otuslinux mdadm]$ sudo parted /dev/md0 mkpart primary ext4 60% 80%
Information: You may need to update /etc/fstab.

[vagrant@otuslinux mdadm]$ sudo parted /dev/md0 mkpart primary ext4 80% 100%
Information: You may need to update /etc/fstab.
[vagrant@otuslinux mdadm]$ ls /dev/md0
md0    md0p1  md0p2  md0p3  md0p4  md0p5

[vagrant@otuslinux mdadm]$  for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=128 blocks, Stripe width=512 blocks
1048576 inodes, 4190208 blocks
209510 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=2151677952
128 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
        4096000

Allocating group tables: done
Writing inode tables: done
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done

[vagrant@otuslinux mdadm]$ sudo mkdir -p /raid/part{1,2,3,4,5}
[vagrant@otuslinux mdadm]$ for i in $(seq 1 5); do sudo mount /dev/md0p$i /raid/part$i; done

[vagrant@otuslinux mdadm]$ sudo cp -r /var/log/* /raid/part1
[vagrant@otuslinux mdadm]$ ls /raid/part1
anaconda  chrony  grubby_prune_debug  maillog   rhsm    spooler   vmware-network.log      wtmp
audit     cron    lastlog             messages  samba   tallylog  vmware-vgauthsvc.log.0  yum.log
btmp      dmesg   lost+found          qemu-ga   secure  tuned     vmware-vmsvc.log
[vagrant@otuslinux mdadm]$
[vagrant@otuslinux ~]$ lsblk
NAME      MAJ:MIN RM SIZE RO TYPE  MOUNTPOINT
sda         8:0    0  40G  0 disk
└─sda1      8:1    0  40G  0 part  /
sdb         8:16   0  20G  0 disk
└─md0       9:0    0  80G  0 raid5
  ├─md0p1 259:0    0  16G  0 md    /raid/part1
  ├─md0p2 259:1    0  16G  0 md    /raid/part2
  ├─md0p3 259:2    0  16G  0 md    /raid/part3
  ├─md0p4 259:3    0  16G  0 md    /raid/part4
  └─md0p5 259:4    0  16G  0 md    /raid/part5
sdc         8:32   0  20G  0 disk
└─md0       9:0    0  80G  0 raid5
  ├─md0p1 259:0    0  16G  0 md    /raid/part1
  ├─md0p2 259:1    0  16G  0 md    /raid/part2
  ├─md0p3 259:2    0  16G  0 md    /raid/part3
  ├─md0p4 259:3    0  16G  0 md    /raid/part4
  └─md0p5 259:4    0  16G  0 md    /raid/part5
sdd         8:48   0  20G  0 disk
└─md0       9:0    0  80G  0 raid5
  ├─md0p1 259:0    0  16G  0 md    /raid/part1
  ├─md0p2 259:1    0  16G  0 md    /raid/part2
  ├─md0p3 259:2    0  16G  0 md    /raid/part3
  ├─md0p4 259:3    0  16G  0 md    /raid/part4
  └─md0p5 259:4    0  16G  0 md    /raid/part5
sde         8:64   0  20G  0 disk
└─md0       9:0    0  80G  0 raid5
  ├─md0p1 259:0    0  16G  0 md    /raid/part1
  ├─md0p2 259:1    0  16G  0 md    /raid/part2
  ├─md0p3 259:2    0  16G  0 md    /raid/part3
  ├─md0p4 259:3    0  16G  0 md    /raid/part4
  └─md0p5 259:4    0  16G  0 md    /raid/part5
sdf         8:80   0  20G  0 disk
└─md0       9:0    0  80G  0 raid5
  ├─md0p1 259:0    0  16G  0 md    /raid/part1
  ├─md0p2 259:1    0  16G  0 md    /raid/part2
  ├─md0p3 259:2    0  16G  0 md    /raid/part3
  ├─md0p4 259:3    0  16G  0 md    /raid/part4
  └─md0p5 259:4    0  16G  0 md    /raid/part5
[vagrant@otuslinux ~]$
```