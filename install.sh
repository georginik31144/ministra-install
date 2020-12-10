#!/bin/bash
#build.xml
#chmod +x install.sh
#./install.sh
while [ $MYSQL_PASSWORD != $MYSQL_PASSWORD_VERIFY ]
    do
        printf "Enter a mysql root password: "
        read -s MYSQL_PASSWORD
        printf "\nConfirm the mysql root password: "
        read -s MYSQL_PASSWORD_VERIFY
        printf "\n"

        if [ $MYSQL_PASSWORD != $MYSQL_PASSWORD_VERIFY ]
            then
                printf "Password do not match. Please try again\n"
        fi
    done

export DEBIAN_FRONTEND=noninteractive

apt update -y

apt upgrade -y

apt install nginx -y

apt install apache2 php7.0-mcrypt php7.0-mbstring nginx memcached mysql-server php php-mysql php-pear nodejs libapache2-mod-php php-curl php-imagick php-sqlite3 unzip -y

pear channel-discover pear.phing.info

apt install phing

pear install -Z phing/phing

printf "Configuring mysql\n"
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_PASSWORD';"
printf "sql_mode=\"\"\n" | tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
mysql -u root -p"$MYSQL_PASSWORD" -e "CREATE DATABASE stalker_db;"
mysql -u root -p"$MYSQL_PASSWORD" -e "GRANT ALL PRIVILEGES ON stalker_db.* TO 'stalker'@'localhost' IDENTIFIED BY '1' WITH GRANT OPTION;"
printf "Restarting mysql\n"
systemctl restart mysql

phpenmod mcrypt
printf "short_open_tag = On\n" | tee -a /etc/php/7.0/apache2/php.ini

printf "Configuring apache\n"
a2enmod rewrite
printf "<VirtualHost *:88>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www
        <Directory /var/www/stalker_portal/>
                Options -Indexes -MultiViews
                AllowOverride ALL
                Require all granted
        </Directory>
        <Directory /var/www/player>
                Options -Indexes -MultiViews
                AllowOverride ALL
                #Require all granted
                DirectoryIndex index.php index.html
        </Directory> 
		ErrorLog ${APACHE_LOG_DIR}/error.log
		CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>\n" | tee /etc/apache2/sites-available/000-default.conf
sed -i 's/Listen 80/Listen 88/' /etc/apache2/ports.conf
printf "Restarting apache\n"
systemctl restart apache2

printf "server {
	listen 80;
	server_name localhost;

root /var/www;
    location ^~ /player {
        root /var/www/player;
        index index.php;
        rewrite ^/player/(.*) /player/$1 break;
        proxy_pass http://127.0.0.1:88/;
        proxy_set_header Host \$host:\$server_port;
        proxy_set_header X-Real-IP \$remote_addr;
    }

	location / {
	proxy_pass http://127.0.0.1:88/;
	proxy_set_header Host \$host:\$server_port;
	proxy_set_header X-Real-IP \$remote_addr;z
	}

	location ~* \.(htm|html|jpeg|jpg|gif|png|css|js)$ {
	root /var/www;
	expires 30d;
	}
}\n" | tee /etc/nginx/sites-available/default
printf "Restarting nginx\n"
systemctl restart nginx

apt install npm -y
npm install -g npm@2.15.11
sudo ln -s /usr/bin/nodejs /usr/bin/node

cd /var/www/
wget http://hub.darkshell.eu/tv/ministra-5.6.1.zip
unzip ministra-5.6.1.zip

cd /var/www/stalker_portal/deploy
wget https://wiki.infomir.eu/wiki/en:article/files/153389291/153389289/1/1603976387000/composer_version_1.9.1.patch
sudo patch -p0 < composer_version_1.9.1.patch

phing
cd ~

printf "Cleaning up environment\n"
unset DEBIAN_FRONTEND

