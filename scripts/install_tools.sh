#!/bin/bash
# Configuramos el script para que se muestren los comandos "x"
# y finalice cuando hay un error en la ejecución "e"
set -ex
echo "Hola mundo"


# Importamos el contenido de las variables de entorno
source .env

# Actualiza la lista de paquetes con permisos
apt update 
# Actualiza los paquetes del sistema operativo y el "-y" ejecuta si pregunta algo 
apt upgrade -y 


# Configuramos las respuestas para la instalación del PHP MyAdmin
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections

# Para instalar phpMyAdmin necesitamos instalar los siguientes paquetes:
apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl -y

# Creamos un directorio para Adminer
mkdir -p /var/www/html/adminer

# Descargamos el archivo PHP de Adminer
wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql.php -P /var/www/html/adminer

# Renombramos el archivo 
mv /var/www/html/adminer/adminer-4.8.1-mysql.php /var/www/html/adminer/index.php

# Creamos una base de datos de ejemplo
mysql -u root <<< "DROP DATABASE IF EXISTS $DB_NAME"
mysql -u root <<< "CREATE DATABASE $DB_NAME"

# Creamos un usuario para la base de datos anterior
mysql -u root <<< "DROP USER IF EXISTS '$DB_USER'@'%'"
mysql -u root <<< "CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%'"

# Instalamos GoAccess
apt install goaccess -y

# Creamos un directorio para las estadísticas de GoAccess
mkdir -p /var/www/html/stats

# Para ejecutar goaccess en segundo plano podemos utilizar la opción
goaccess /var/log/apache2/access.log -o /var/www/html/stats/index.html --log-format=COMBINED --real-time-html --daemonize

# Control de acceso a un directorio con autenticacion  básica
cp ../conf/000-default-stats.conf /etc/apache2/sites-available

# Deshabilitamos el virtualhost 000-default-conf
a2dissite 000-default.conf

# Habilitamos el nuevo virtualhost
a2ensite 000-default-stats.conf

# Hacemos un reload del proceso
systemctl reload apache2

# Creamos el archivo .htaccess
sudo htpasswd -bc /etc/apache2/.htpasswd $STATS_USERNAME $STATS_PASSWORD

cp ../conf/000-default-htaccess.conf /etc/apache2/sites-available

# Deshabilitamos el nuevo virtualhost 000-stats.conf
a2dissite 000-default-stats.conf

# Habilitamos el nuevo 
a2ensite 000-default-htaccess.conf

# Hacemos reload al proceso de Apache
systemctl reload apache2
