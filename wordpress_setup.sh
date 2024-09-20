#!/bin/bash

#variables
DDNS_KEY=
DDNS_PASS=
HOSTNAME=
WORDPRESS_ROOT_PASS=

#install php, nysql and libs
apt install apache2 mariadb-server ghostscript libapache2-mod-php mysql-server php curl php-gd php-bcmath php-curl php-imagick php-intl php-json php-mbstring php-mysql php-xml php-zip snapd -y

#download and extract wordpress
cd /var/www/html/
rm *
wget https://wordpress.org/latest.tar.gz
tar xzf latest.tar.gz
mv wordpress/* .
rm -rf wordpress latest.tar.gz
chown -R www-data: .

#install no-ip
cd /home/$USER/noip-duc_3.3.0/binaries
wget --content-disposition https://www.noip.com/download/linux/latest
tar xf noip-duc_3.3.0.tar.gz
apt install ./noip-duc_3.3.0_amd64.deb
cp service /etc/systemd/system/noip-duc.service
noip-duc -g all.ddnskey.com --username $DDNS_KEY --password $DDNS_PASS

#database installation
mysql_secure_installation
mysql -uroot -p -e 'create database wordpress;'
mysql -uroot -p -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'localhost' IDENTIFIED BY '$WORDPRESS_ROOT_PASS';"
#wordpress config
#TODO
#certificates installation
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot
certbot --apache