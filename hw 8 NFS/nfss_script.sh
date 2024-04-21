#!/bin/bash
# Update kernel
yum install -y epel-release kernel-devel
#Install nfs-utils
yum install nfs-utils
# Enable Firewall
systemctl enable firewalld --now
# Allow nfs3 firewall
firewall-cmd --add-service="nfs3" \
			 --add-service="rpc-bind" \
			 --add-service="mountd" \
			 --permanent
firewall-cmd --reload
# Enable NFS
systemctl enable nfs --now

# Creating dir and share

mkdir -p /srv/share/upload
chown -R nfsnobody:nfsnobody /srv/share
chmod 0777 /srv/share/upload

cat << EOF > /etc/exports 
/srv/share 192.168.50.11/32(rw,sync,root_squash)
EOF

exportfs -r 
