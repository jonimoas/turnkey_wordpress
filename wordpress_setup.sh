#!/bin/bash

#variables
DDNS_KEY=
DDNS_PASS=
HOSTNAME=
WORDPRESS_ROOT_PASS=

#install php, nysql and libs
apt install apache2 mariadb-server ghostscript libapache2-mod-php php curl php-gd php-bcmath php-curl php-imagick php-intl php-json php-mbstring php-mysql php-xml php-zip snapd -y
echo "Libs installed"

#download and extract wordpress
cd /var/www/html/
rm *
wget https://wordpress.org/latest.tar.gz
tar xzf latest.tar.gz
mv wordpress/* .
rm -rf wordpress latest.tar.gz
chown -R www-data: .
echo "Wordpress extracted"

#install noip
cd /root
rm -rf no-ip
mkdir no-ip
wget --content-disposition -O noip-duc.tar.gz https://www.noip.com/download/linux/latest
tar -xf noip-duc.tar.gz -C ./no-ip --strip-components=1
chmod 777 /root/no-ip/binaries/*.deb
apt install /root/no-ip/binaries/*amd64.deb
cd "/root/no-ip/debian"
cp service /etc/systemd/system/noip-duc.service
echo "noip installed"

echo "starting noip and setting up systemd service"
systemctl daemon-reload
systemctl enable noip-duc.service
touch /etc/default/noip-duc
cd /etc/default
echo NOIP_USERNAME=$DDNS_KEY >> noip-duc
echo NOIP_PASSWORD=$DDNS_PASS >> noip-duc
echo NOIP_HOSTNAMES=$HOSTNAME >> noip-duc
systemctl start noip-duc.service

echo "starting db install"
#database installation
mysql_secure_installation <<EOF
$WORDPRESS_ROOT_PASS
Y
Y
Y
Y
Y
EOF
mysql -uroot -p"$WORDPRESS_ROOT_PASS" -e 'create database wordpress;'
mysql -uroot -p"$WORDPRESS_ROOT_PASS" -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'localhost' IDENTIFIED BY '$WORDPRESS_ROOT_PASS';"

#certificates installation
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot
certbot --apache
echo "setup complete"
