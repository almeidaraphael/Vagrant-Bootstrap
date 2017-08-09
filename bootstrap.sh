#!/usr/bin/env bash

PROJECTNAME='gdp'

# create project folder
sudo mkdir "/var/www/html/${PROJECTNAME}"

echo "---------- Adding PPAs ----------"
sudo add-apt-repository ppa:ondrej/php

echo "---------- Update / Upgrade packages ----------"
sudo apt-get update
sudo apt-get upgrade

echo "---------- Install tools and helpers ----------"
sudo apt-get install -y --force-yes curl
sudo apt-get install -y --force-yes git
sudo apt-get install -y --force-yes vim

echo "---------- Install Apache ----------"
sudo apt-get install -y --force-yes apache2

echo "---------- Install MySQL ----------"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password root"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root"
sudo apt-get install -y --force-yes mysql-server

echo "---------- Install PHP 7 ----------"
sudo apt-get install -y --force-yes php7.0-common
sudo apt-get install -y --force-yes php7.0-dev
sudo apt-get install -y --force-yes php7.0-json
sudo apt-get install -y --force-yes php7.0-opcache
sudo apt-get install -y --force-yes php7.0-cli
sudo apt-get install -y --force-yes libapache2-mod-php7.0
sudo apt-get install -y --force-yes php7.0
sudo apt-get install -y --force-yes php7.0-mysql
sudo apt-get install -y --force-yes php7.0-fpm
sudo apt-get install -y --force-yes php7.0-curl
sudo apt-get install -y --force-yes php7.0-gd
sudo apt-get install -y --force-yes php7.0-mcrypt
sudo apt-get install -y --force-yes php7.0-mbstring
sudo apt-get install -y --force-yes php7.0-bcmath
sudo apt-get install -y --force-yes php7.0-zip
sudo apt-get install -y --force-yes php7.0-xml

echo "---------- Creating virtual hosts ----------"
echo "ServerName server.local" | sudo tee -a /etc/apache2/apache2.conf
cat << EOF | sudo tee -a /etc/apache2/sites-available/default.conf
<VirtualHost *:80>
  DocumentRoot "/var/www/html/${PROJECTNAME}/public"
  ServerName server.local
  ErrorLog ${APACHE_LOG_DIR}/error.log
  CustomLog ${APACHE_LOG_DIR}/acces.log combined
  <Directory "/var/www/html/${PROJECTNAME}/public">
    AllowOverride All
    Require all granted
  </Directory>
</VirtualHost>
EOF
sudo a2ensite default.conf
sudo a2dissite 000-default.conf

echo "---------- Configure PHP & Apache ----------"
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/apache2/php.ini
sudo a2enmod rewrite

echo "---------- Restart Apache ----------"
sudo service apache2 restart

echo "---------- Install Composer ----------"
curl -s https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

echo "---------- Setup database ----------"
mysql -uroot -proot -e "CREATE DATABASE ${PROJECTNAME}";

echo "---------- Finishing Touches ----------"
sudo apt-get autoremove