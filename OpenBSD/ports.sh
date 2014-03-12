echo " Installing the ports system ! "
cd /tmp
curl -O http://ftp.eu.openbsd.org/pub/OpenBSD/5.4/ports.tar.gz
cd /usr
sudo mkdir ports
sudo chown vagrant:vagrant ports
sudo -u vagrant tar xzf /tmp/ports.tar.gz
cd /usr/ports
sudo sh -c "echo 'SUDO=sudo -E' >> /etc/mk.conf"
