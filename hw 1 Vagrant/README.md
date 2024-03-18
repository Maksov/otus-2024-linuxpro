## Домашее задание № 1 Vagrant

### Занятие 1. Vagrant-стенд для обновления ядра и создания образа системы
Цель домашнего задания
Научиться обновлять ядро в ОС Linux. Получение навыков работы с Vagrant. 
Описание домашнего задания
1) Запустить ВМ с помощью Vagrant.
2) Обновить ядро ОС из репозитория ELRepo.
3) Оформить отчет в README-файле в GitHub-репозитории.


1. Настроено рабочее окружение
	- Windows 10
	- VMware Workstation Pro
	- Vagrant
	- Vagrant-Vmware-Utility
2. Порядок выполнения задания

```
C:\Users\Maksim\Documents\GitHub\otus-2024-linuxpro>vagrant up
Bringing machine 'kernel-update' up with 'vmware_workstation' provider...
==> kernel-update: Box 'generic/centos8s' could not be found. Attempting to find and install...
    kernel-update: Box Provider: vmware_desktop, vmware_fusion, vmware_workstation
    kernel-update: Box Version: 4.3.4
==> kernel-update: Loading metadata for box 'generic/centos8s'
    kernel-update: URL: https://vagrantcloud.com/api/v2/vagrant/generic/centos8s
==> kernel-update: Adding box 'generic/centos8s' (v4.3.4) for provider: vmware_desktop (amd64)
    kernel-update: Downloading: https://vagrantcloud.com/generic/boxes/centos8s/versions/4.3.4/providers/vmware_desktop/amd64/vagrant.box
==> kernel-update: Box download is resuming from prior download progress
    kernel-update:
    kernel-update: Calculating and comparing box checksum...
==> kernel-update: Successfully added box 'generic/centos8s' (v4.3.4) for 'vmware_desktop (amd64)'!
==> kernel-update: Cloning VMware VM: 'generic/centos8s'. This can take some time...
==> kernel-update: Checking if box 'generic/centos8s' version '4.3.4' is up to date...
==> kernel-update: Verifying vmnet devices are healthy...
==> kernel-update: Preparing network adapters...
==> kernel-update: Starting the VMware VM...
==> kernel-update: Waiting for the VM to receive an address...
==> kernel-update: Forwarding ports...
    kernel-update: -- 22 => 2222
==> kernel-update: Waiting for machine to boot. This may take a few minutes...
    kernel-update: SSH address: 127.0.0.1:2222
    kernel-update: SSH username: vagrant
    kernel-update: SSH auth method: private key
    kernel-update:
    kernel-update: Vagrant insecure key detected. Vagrant will automatically replace
    kernel-update: this with a newly generated keypair for better security.
    kernel-update:
    kernel-update: Inserting generated public key within guest...
    kernel-update: Removing insecure key from the guest if it's present...
    kernel-update: Key inserted! Disconnecting and reconnecting using new SSH key...
==> kernel-update: Machine booted and ready!
==> kernel-update: Setting hostname...
==> kernel-update: Configuring network adapters within the VM...
C:\Users\Maksim\Documents\GitHub\otus-2024-linuxpro\hw 1 Vagrant>vagrant ssh
[vagrant@kernel-update ~]$ uname -r
4.18.0-516.el8.x86_64
[vagrant@kernel-update ~]$ sudo yum install -y https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm
CentOS Stream 8 - AppStream                                                             4.8 MB/s |  28 MB     00:05
CentOS Stream 8 - BaseOS                                                                6.3 MB/s |  10 MB     00:01
CentOS Stream 8 - Extras                                                                 26 kB/s |  18 kB     00:00
CentOS Stream 8 - Extras common packages                                                 12 kB/s | 7.5 kB     00:00
Extra Packages for Enterprise Linux 8 - x86_64                                          6.0 MB/s |  16 MB     00:02
Extra Packages for Enterprise Linux 8 - Next - x86_64                                   231 kB/s | 368 kB     00:01
elrepo-release-8.el8.elrepo.noarch.rpm                                                  9.2 kB/s |  13 kB     00:01
Dependencies resolved.
========================================================================================================================
 Package                       Architecture          Version                          Repository                   Size
========================================================================================================================
Installing:
 elrepo-release                noarch                8.3-1.el8.elrepo                 @commandline                 13 k

Transaction Summary
========================================================================================================================
Install  1 Package

Total size: 13 k
Installed size: 5.0 k
Downloading Packages:
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                1/1
  Installing       : elrepo-release-8.3-1.el8.elrepo.noarch                                                         1/1
  Verifying        : elrepo-release-8.3-1.el8.elrepo.noarch                                                         1/1

Installed:
  elrepo-release-8.3-1.el8.elrepo.noarch

Complete!
[vagrant@kernel-update ~]$ sudo yum --enablerepo elrepo-kernel install kernel-ml -y
CentOS Stream 8 - AppStream                                                             9.8 kB/s | 4.4 kB     00:00
CentOS Stream 8 - BaseOS                                                                8.4 kB/s | 3.9 kB     00:00
CentOS Stream 8 - Extras                                                                8.2 kB/s | 2.9 kB     00:00
CentOS Stream 8 - Extras common packages                                                8.2 kB/s | 3.0 kB     00:00
ELRepo.org Community Enterprise Linux Repository - el8                                   86 kB/s | 203 kB     00:02
ELRepo.org Community Enterprise Linux Kernel Repository - el8                           1.2 MB/s | 2.2 MB     00:01
Extra Packages for Enterprise Linux 8 - x86_64                                           65 kB/s |  33 kB     00:00
Extra Packages for Enterprise Linux 8 - x86_64                                          4.3 MB/s |  16 MB     00:03
Extra Packages for Enterprise Linux 8 - Next - x86_64                                    33 kB/s |  35 kB     00:01
Dependencies resolved.
========================================================================================================================
 Package                        Architecture        Version                            Repository                  Size
========================================================================================================================
Installing:
 kernel-ml                      x86_64              6.8.1-1.el8.elrepo                 elrepo-kernel              123 k
Installing dependencies:
 kernel-ml-core                 x86_64              6.8.1-1.el8.elrepo                 elrepo-kernel               39 M
 kernel-ml-modules              x86_64              6.8.1-1.el8.elrepo                 elrepo-kernel               34 M

Transaction Summary
========================================================================================================================
Install  3 Packages

Total download size: 73 M
Installed size: 115 M
Downloading Packages:
(1/3): kernel-ml-6.8.1-1.el8.elrepo.x86_64.rpm                                          212 kB/s | 123 kB     00:00
(2/3): kernel-ml-modules-6.8.1-1.el8.elrepo.x86_64.rpm                                  5.9 MB/s |  34 MB     00:05
(3/3): kernel-ml-core-6.8.1-1.el8.elrepo.x86_64.rpm                                     5.2 MB/s |  39 MB     00:07
------------------------------------------------------------------------------------------------------------------------
Total                                                                                   9.2 MB/s |  73 MB     00:07
ELRepo.org Community Enterprise Linux Kernel Repository - el8                           1.6 MB/s | 1.7 kB     00:00
Importing GPG key 0xBAADAE52:
 Userid     : "elrepo.org (RPM Signing Key for elrepo.org) <secure@elrepo.org>"
 Fingerprint: 96C0 104F 6315 4731 1E0B B1AE 309B C305 BAAD AE52
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-elrepo.org
Key imported successfully
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                1/1
  Installing       : kernel-ml-core-6.8.1-1.el8.elrepo.x86_64                                                       1/3
  Running scriptlet: kernel-ml-core-6.8.1-1.el8.elrepo.x86_64                                                       1/3
  Installing       : kernel-ml-modules-6.8.1-1.el8.elrepo.x86_64                                                    2/3
  Running scriptlet: kernel-ml-modules-6.8.1-1.el8.elrepo.x86_64                                                    2/3
  Installing       : kernel-ml-6.8.1-1.el8.elrepo.x86_64                                                            3/3
  Running scriptlet: kernel-ml-core-6.8.1-1.el8.elrepo.x86_64                                                       3/3
dracut: Disabling early microcode, because kernel does not support it. CONFIG_MICROCODE_[AMD|INTEL]!=y
dracut: Disabling early microcode, because kernel does not support it. CONFIG_MICROCODE_[AMD|INTEL]!=y

  Running scriptlet: kernel-ml-6.8.1-1.el8.elrepo.x86_64                                                            3/3
  Verifying        : kernel-ml-6.8.1-1.el8.elrepo.x86_64                                                            1/3
  Verifying        : kernel-ml-core-6.8.1-1.el8.elrepo.x86_64                                                       2/3
  Verifying        : kernel-ml-modules-6.8.1-1.el8.elrepo.x86_64                                                    3/3

Installed:
  kernel-ml-6.8.1-1.el8.elrepo.x86_64                          kernel-ml-core-6.8.1-1.el8.elrepo.x86_64
  kernel-ml-modules-6.8.1-1.el8.elrepo.x86_64

Complete!

[vagrant@kernel-update ~]$ sudo grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
done
[vagrant@kernel-update ~]$ sudo grub2-set-default 0

C:\Users\Maksim\Documents\GitHub\otus-2024-linuxpro\hw 1 Vagrant>vagrant ssh
Last login: Mon Mar 18 07:57:56 2024 from 192.168.190.2
[vagrant@kernel-update ~]$ uname -r
6.8.1-1.el8.elrepo.x86_64
[vagrant@kernel-update ~]$
```