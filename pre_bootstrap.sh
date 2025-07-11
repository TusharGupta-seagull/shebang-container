#!/bin/bash
echo "[+] Setting DNS to 8.8.8.8"
echo "nameserver 8.8.8.8" > /etc/resolv.conf

echo "[+] Updating yum repo to use vault.centos.org"
sed -i 's|^mirrorlist=|#mirrorlist=|g' /etc/yum.repos.d/CentOS-Base.repo
sed -i 's|^#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Base.repo

yum clean all
yum makecache