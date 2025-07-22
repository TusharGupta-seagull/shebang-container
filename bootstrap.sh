#!/bin/bash
set -e

echo "[+] Installing required packages..."

yum install -y epel-release
yum install -y autoconf automake btrfs-progs docker \
               gettext-devel git libcgroup-tools libtool \
               python2-pip iproute iptables bridge-utils jq

echo "[+] Setting up Btrfs loopback filesystem..."

fallocate -l 10G /root/btrfs.img
mkdir -p /var/shebang-con
mkfs.btrfs -f /root/btrfs.img
mount -o loop /root/btrfs.img /var/shebang-con 
echo "/root/btrfs.img /var/shebang-con btrfs loop 0 0" | sudo tee -a /etc/fstab

echo "[+] Installing Python 3 and pip..."
yum install -y python3 python3-pip
python3 -m pip install --upgrade pip
python3 -m pip install setuptools wheel

echo "[+] Python version:"
python3 --version
echo "[+] Pip version:"
python3 -m pip --version

echo "[+] Installing undocker tool..."
python3 -m pip install git+https://github.com/larsks/undocker
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
source ~/.bashrc

echo "[+] Verifying undocker installation..."
which undocker || echo "ERROR: undocker not found in PATH."

echo "[+] Starting Docker and downloading base image..."
systemctl enable docker
systemctl start docker
docker pull centos:7
docker save centos:7 | undocker -o /var/shebang-con/base-image

echo "[+] Cloning and building util-linux for unshare..."
cd /tmp
git clone https://github.com/karelzak/util-linux.git
cd util-linux
git checkout tags/v2.25.2
./autogen.sh
./configure --without-ncurses --without-python
make -j$(nproc)
cp unshare /usr/bin/unshare
cd ..
rm -rf util-linux

echo "[+] Linking your shebang-con script..."
ln -sf /vagrant/shebang-con /usr/bin/shebang-con
chmod +x /usr/bin/shebang-con

echo "[+] Setting up bridge networking..."
echo 1 > /proc/sys/net/ipv4/ip_forward

iptables --flush
iptables -t nat -F
iptables -t nat -A POSTROUTING -o bridge0 -j MASQUERADE

ip link add bridge0 type bridge || true
ip addr add 10.0.0.1/24 dev bridge0
ip link set bridge0 up

echo "[#] Environment setup complete."
