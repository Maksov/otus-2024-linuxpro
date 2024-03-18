## Домашее задание № 2 Ansible

### Занятие 2. Первые шаги с Ansible

#### Цель домашнего задания
Написать первые шаги с Ansible.
#### Описание домашнего задания
Подготовить стенд на Vagrant как минимум с одним сервером. На этом сервере, используя Ansible необходимо развернуть nginx со следующими условиями:
- необходимо использовать модуль yum/apt
- конфигурационный файлы должны быть взяты из шаблона jinja2 с переменными
- после установки nginx должен быть в режиме enabled в systemd
- должен быть использован notify для старта nginx после установки
- сайт должен слушать на нестандартном порту - 8080, для этого использовать переменные в Ansible

1. Настроено рабочее окружение
	- Windows 10
	- VMware Workstation Pro
	- Vagrant
	- Vagrant-Vmware-Utility
	- WSL2 Ubuntu - внутри ansible
2. Порядок выполнения задания

- Настраиваем конфигурационный файл Vagrant  и запускаем ВМ 
```
MACHINES = {
  :nginx => {
        :box_name => "generic/ubuntu2204",
        :vm_name => "nginx",
        :net => [
           ["192.168.11.150", "255.255.255.0"],
        ]
  }
}

Vagrant.configure("2") do |config|

  MACHINES.each do |boxname, boxconfig|

    config.vm.define boxname do |box|
   
      box.vm.box = boxconfig[:box_name]
      box.vm.host_name = boxconfig[:vm_name]
      
      box.vm.provider "vmware_workstation" do |v|
        v.memory = 1024
        v.cpus = 2
       end

      boxconfig[:net].each do |ipconf|
        box.vm.network("private_network", ip: ipconf[0], netmask: ipconf[1])
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

C:\Users\Maksim\Documents\GitHub\otus-2024-linuxpro\hw 2 Ansible>vagrant up
Bringing machine 'nginx' up with 'vmware_workstation' provider...
==> nginx: Box 'generic/ubuntu2204' could not be found. Attempting to find and install...
    nginx: Box Provider: vmware_desktop, vmware_fusion, vmware_workstation
    nginx: Box Version: >= 0
==> nginx: Loading metadata for box 'generic/ubuntu2204'
    nginx: URL: https://vagrantcloud.com/api/v2/vagrant/generic/ubuntu2204
==> nginx: Adding box 'generic/ubuntu2204' (v4.3.12) for provider: vmware_desktop (amd64)
    nginx: Downloading: https://vagrantcloud.com/generic/boxes/ubuntu2204/versions/4.3.12/providers/vmware_desktop/amd64/vagrant.box
==> nginx: Box download is resuming from prior download progress
    nginx:
    nginx: Calculating and comparing box checksum...
==> nginx: Successfully added box 'generic/ubuntu2204' (v4.3.12) for 'vmware_desktop (amd64)'!
==> nginx: Cloning VMware VM: 'generic/ubuntu2204'. This can take some time...
==> nginx: Checking if box 'generic/ubuntu2204' version '4.3.12' is up to date...
==> nginx: Verifying vmnet devices are healthy...
==> nginx: Preparing network adapters...
==> nginx: Fixed port collision for 22 => 2222. Now on port 2200.
==> nginx: Starting the VMware VM...
==> nginx: Waiting for the VM to receive an address...
==> nginx: Forwarding ports...
    nginx: -- 22 => 2200
==> nginx: Waiting for machine to boot. This may take a few minutes...
    nginx: SSH address: 127.0.0.1:2200
    nginx: SSH username: vagrant
    nginx: SSH auth method: private key
    nginx: Warning: Connection reset. Retrying...
    nginx: Warning: Connection aborted. Retrying...
    nginx: Warning: Connection aborted. Retrying...
    nginx: Warning: Connection reset. Retrying...
    nginx: Warning: Remote connection disconnect. Retrying...
    nginx: Warning: Connection aborted. Retrying...
    nginx: Warning: Connection reset. Retrying...
    nginx: Warning: Connection aborted. Retrying...
    nginx: Warning: Connection reset. Retrying...
    nginx: Warning: Remote connection disconnect. Retrying...
    nginx: Warning: Connection aborted. Retrying...
    nginx: Warning: Connection reset. Retrying...
    nginx: Warning: Connection aborted. Retrying...
    nginx: Warning: Remote connection disconnect. Retrying...
    nginx: Warning: Connection reset. Retrying...
    nginx: Warning: Connection aborted. Retrying...
    nginx: Warning: Connection reset. Retrying...
    nginx: Warning: Connection aborted. Retrying...
    nginx: Warning: Connection reset. Retrying...
    nginx: Warning: Connection aborted. Retrying...
    nginx: Warning: Connection reset. Retrying...
    nginx: Warning: Connection aborted. Retrying...
    nginx: Warning: Remote connection disconnect. Retrying...
    nginx: Warning: Connection reset. Retrying...
    nginx: Warning: Connection aborted. Retrying...
    nginx: Warning: Remote connection disconnect. Retrying...
    nginx: Warning: Connection reset. Retrying...
    nginx: Warning: Connection aborted. Retrying...
    nginx:
    nginx: Vagrant insecure key detected. Vagrant will automatically replace
    nginx: this with a newly generated keypair for better security.
    nginx:
    nginx: Inserting generated public key within guest...
    nginx: Removing insecure key from the guest if it's present...
    nginx: Key inserted! Disconnecting and reconnecting using new SSH key...
==> nginx: Machine booted and ready!
==> nginx: Setting hostname...
==> nginx: Configuring network adapters within the VM...
==> nginx: Running provisioner: shell...
    nginx: Running: inline script
```

- Проверяем версию ansible в WSL2 Ubuntu
```
maksim@DESKTOP-DHVBQLG:~/hw2ansible$ ansible --version
ansible [core 2.12.3]
  config file = /home/maksim/hw2ansible/ansible.cfg
  configured module search path = ['/home/maksim/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /home/maksim/.local/lib/python3.8/site-packages/ansible
  ansible collection location = /home/maksim/.ansible/collections:/usr/share/ansible/collections
  executable location = /home/maksim/.local/bin/ansible
  python version = 3.8.2 (default, Mar 13 2020, 10:14:16) [GCC 9.3.0]
  jinja version = 2.10.1
  libyaml = True
```
- настраиваем конфигурационный файл Ansible.cfg и файл инвентаризации hosts
```
т.к. сеть с WSL2 отличается настраиваем по ip виртуальной машины vagrant
```
- проверяем настройку командой ping
```
maksim@DESKTOP-DHVBQLG:~/hw2ansible$ ansible nginx -m ping
nginx | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```
- пишем yml файл запуска и настройки NGINX согласно методичке (см. ngninx.yml)
- запускаем плейбук
```
maksim@DESKTOP-DHVBQLG:~/hw2ansible$ ansible-playbook nginx.yml

PLAY [NGINX | Install and configure NGINX] *****************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [nginx]

TASK [update] **********************************************************************************************************
changed: [nginx]

TASK [NGINX | Install NGINX] *******************************************************************************************
ok: [nginx]

TASK [NGINX | Create NGINX config file from template] ******************************************************************
ok: [nginx]

PLAY RECAP *************************************************************************************************************
nginx                      : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
- Проверяем запуск NGINX командой curl
```
maksim@DESKTOP-DHVBQLG:~/hw2ansible$ curl http://192.168.190.149:8080
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```
