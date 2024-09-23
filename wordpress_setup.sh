#!/bin/bash

#variables
DDNS_KEY=
DDNS_PASS=
HOSTNAME=
WORDPRESS_ROOT_PASS=

#install php, nysql and libs
apt install apache2 mariadb-server ghostscript libapache2-mod-php php curl php-gd php-bcmath php-curl php-imagick php-intl php-json php-mbstring php-mysql php-xml php-zip snapd -y
read -p "Libs installed"

#download and extract wordpress
cd /var/www/html/
rm *
wget https://wordpress.org/latest.tar.gz
tar xzf latest.tar.gz
mv wordpress/* .
rm -rf wordpress latest.tar.gz
chown -R www-data: .
read -p "Wordpress extracted"

#install noip
cd /root
wget --content-disposition https://www.noip.com/download/linux/latest
tar xf noip-duc_3.3.0.tar.gz
cd noip-duc_3.3.0/binaries
chmod 777 noip-duc_3.3.0_amd64.deb
apt install ./noip-duc_3.3.0_amd64.deb
cd /root/noip-duc_3.3.0/debian
cp service /etc/systemd/system/noip-duc.service
read -p "noip installed"

read -p "starting noip and setting up systemd service"
systemctl daemon-reload
systemctl enable noip-duc.service
touch /etc/default/noip-duc
cd /etc/default
echo NOIP_USERNAME=$DDNS_KEY >> noip-duc
echo NOIP_PASSWORD=$DDNS_PASS >> noip-duc
echo NOIP_HOSTNAMES=$HOSTNAME >> noip-duc
systemctl start noip-duc.service

read -p "starting db install, enter root pass and answer Y to all"
#database installation
mysql_secure_installation
read -p "please add two more times the db root pass"
mysql -uroot -p -e 'create database wordpress;'
mysql -uroot -p -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'localhost' IDENTIFIED BY '$WORDPRESS_ROOT_PASS';"

#certificates installation
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot
certbot --apache
read -p "installed certificates, setup complete"