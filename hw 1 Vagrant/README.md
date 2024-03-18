## 






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
```