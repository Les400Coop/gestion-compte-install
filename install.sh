#!/bin/bash

PHP_VERSION="7.2"

apt-get install apache2 || exit 1

useradd -m -G www-data -s /bin/false php-user || exit 1

apt-get install phpmyadmin php-${PHP_VERSION}-mbstring php-${PHP_VERSION}-gettext php-${PHP_VERSION}-zip php-${PHP_VERSION}-fpm php-${PHP_VERSION}-xml php-${PHP_VERSION}-gd git patch less wget certbot || exit 1

systemctl enable php7.2-fpm || exit 1
systemctl start php7.2-fpm || exit 1


#Apache

systemctl enable apache2 || exit 1

a2enmod proxy_fcgi || exit 1
a2enconf php${PHP_VERSION}-fpm || exit 1

phpenmod mbstring || exit 1


cp /root/gestion-compte-install/001-membres-les400coop.conf /etc/apache2/sites-available || exit 1
cp /root/gestion-compte-install/000-default.conf /etc/apache2/sites-available || exit 1

a2ensite 001-membres-les400coop || exit 1
a2ensite 000-default.conf || exit 1

systemctl restart apache2 || exit 1

#LetsEncrypt

certbot certonly -n --webroot --webroot-path /var/www/html --cert-name membres.les400coop.fr -d membres.les400coop.fr --post-hook "systemctl reload apache2" || exit 1


#Install app

cd /home/php-user || exit 1
#@https://getcomposer.org/download/
sudo -u php-user php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" || exit 1
sudo -u php-user php -r "if (hash_file('SHA384', 'composer-setup.php') === '93b54496392c062774670ac18b134c3b3a95e5a5e5c8f1a9f115f203b75bf9a129d5daa8ba6a13e2cc8a1da0806388a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" || exit 1
sudo -u php-user php composer-setup.php || exit 1
sudo -u php-user php -r "unlink('composer-setup.php');" || exit 1

sudo -u php-user git clone https://github.com/Les400Coop/gestion-compte.git || exit 1
cd /home/php-user/gestion-compte || exit 1
cp /root/gestion-compte-install/parameters.yml app/config || exit 1
sudo -u php-user php /home/php-user/composer.phar install || exit 1
