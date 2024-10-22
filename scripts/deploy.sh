#!/bin/bash
# Configuramos el script para que se muestren los comando
# y finalice cuando hay un error en la ejecucion
set -ex

# Importamos el archivo .env
source .env

# Eliminamos clonados previos del repositorio 
rm -rf /tmp/iaw-practica-lamp

# Clonamos el repositorio de la aplicación en /tmp/daw-practica-lamp
git clone https://github.com/josejuansanchez/iaw-practica-lamp /tmp/iaw-practica-lamp

# Movemos el código fuente del directorio src al directorio /var/www/html
mv /tmp/iaw-practica-lamp/src/* /var/www/html

# Creamos una base de datos para la aplicación
mysql -u root <<< "DROP DATABASE IF EXISTS $DB_NAME"
mysql -u root <<< "CREATE DATABASE $DB_NAME"

# Creamos un usuario para la base de datos anterior
mysql -u root <<< "DROP USER IF EXISTS '$DB_USER'@'%'"
mysql -u root <<< "CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%'"

# Configuramos el archivo config.php
sed -i "s/database_name_here/$DB_NAME/" /var/www/html/config.php
sed -i "s/username_here/$DB_USER/" /var/www/html/config.php
sed -i "s/password_here/$DB_PASSWORD/" /var/www/html/config.php

# Configuramos el archivo .sql
sed -i "s/lamp_db/$DB_NAME/" /tmp/iaw-practica-lamp/db/database.sql

# Ejecutamos el script de SQL para crear las tablas (< significa ejecución línea a línea)
mysql -u root < /tmp/iaw-practica-lamp/db/database.sql