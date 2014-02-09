FQDN='vagrant-arch32X.vargrantup.com'
TIMEZONE='UTC'
KEYMAP='gb'
LANGUAGE='en_GB.UTF-8'
PASSWORD=$(/usr/bin/openssl passwd -crypt 'vagrant')

echo "${FQDN}" > /etc/hostname
/usr/bin/ln -s /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
echo "KEYMAP=${KEYMAP}" > /etc/vconsole.conf
/usr/bin/sed -i "s/#${LANGUAGE}/${LANGUAGE}/" /etc/locale.gen
/usr/bin/locale-gen
/usr/bin/mkinitcpio -p linux
/usr/bin/usermod --password ${PASSWORD} root
# https://wiki.archlinux.org/index.php/Network_Configuration#Device_names
/usr/bin/ln -s /dev/null /etc/udev/rules.d/80-net-name-slot.rules
/usr/bin/ln -s "/usr/lib/systemd/system/dhcpcd@.service" "/etc/systemd/system/multi-user.target.wants/dhcpcd@eth0.service"
/usr/bin/sed -i "s/#UseDNS yes/UseDNS no/" /etc/ssh/sshd_config
/usr/bin/systemctl enable sshd.service

# VirtualBox Guest Additions
/usr/bin/pacman -S --noconfirm linux-headers virtualbox-guest-utils virtualbox-guest-dkms
echo -e "vboxguest\nvboxsf\nvboxvideo" > /etc/modules-load.d/virtualbox.conf
guest_version=$(/usr/bin/pacman -Q virtualbox-guest-dkms | awk '{ print $2 }' | cut -d'-' -f1)
kernel_version="$(/usr/bin/pacman -Q linux | awk '{ print $2 }')-ARCH"
/usr/bin/dkms install "vboxguest/${guest_version}" -k "${kernel_version}/x86_64"
/usr/bin/systemctl enable dkms.service
/usr/bin/systemctl enable vboxservice.service

# Vagrant-specific configuration
/usr/bin/groupadd vagrant
/usr/bin/useradd --password ${PASSWORD} --comment 'Vagrant User' --create-home --gid users --groups vagrant,vboxsf vagrant
echo 'Defaults env_keep += "SSH_AUTH_SOCK"' > /etc/sudoers.d/10_vagrant
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/10_vagrant
/usr/bin/chmod 0440 /etc/sudoers.d/10_vagrant
/usr/bin/install --directory --owner=vagrant --group=users --mode=0700 /home/vagrant/.ssh
/usr/bin/curl --output /home/vagrant/.ssh/authorized_keys https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub
/usr/bin/chown vagrant:users /home/vagrant/.ssh/authorized_keys
/usr/bin/chmod 0600 /home/vagrant/.ssh/authorized_keys

# clean up
/usr/bin/pacman -Rcns --noconfirm gptfdisk
/usr/bin/pacman -Scc --noconfirm
