#!/bin/bash
# Configuramos el script para que se muestren los comandos "x"
# y finalice cuando hay un error en la ejecución "e"
set -ex
echo "Hola mundo"
# Actualiza la lista de paquetes con permisos
apt update 
# Actualiza los paquetes del sistema operativo y el "-y" ejecuta si pregunta algo 
apt upgrade -y 
# Instalamos el servidor web apache 
apt install apache2 -y

# Copiamos nuestro archivo de configuración de VirtualHost
cp ../conf/000-default.conf /etc/apache2/sites-available/

# Instalamos los paquetes necesarios para tener PHP
sudo apt install php libapache2-mod-php php-mysql -y

# Habilitamos el módulo rewrite de Apache
a2enmod rewrite

# Reiniciamos el servicio apache2
systemctl restart apache2

# Copiamos el archivo index.php 
cp ../php/index.php /var/www/html


# Modificamos el propietario del directorio /var/www/html
chown -R www-data:www-data /var/www/html

# Instalamos MySQL Server
apt install mysql-server -y