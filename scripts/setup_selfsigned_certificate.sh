#!/bin/bash

# Configuramos el script para que se muestren los comando
# y finalice cuando hay un error en la ejecucion
set -ex

# Importamos el archivo .env
source .env

# Comprobamos que tenemos instalado -> openssl (nos deben salir todas las herramientas con el menú de ayuda)

# Creamos el certificado autofirmado
sudo openssl req \
  -x509 \
  -nodes \
  -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/ssl/private/apache-selfsigned.key \
  -out /etc/ssl/certs/apache-selfsigned.crt \
  -subj "/C=$OPENSSL_COUNTRY/ST=$OPENSSL_PROVINCE/L=$OPENSSL_LOCALITY/O=$OPENSSL_ORGANIZATION/OU=$OPENSSL_ORGUNIT/CN=$OPENSSL_COMMON_NAME/emailAddress=$OPENSSL_EMAIL"

# Copiamos el archivo default-ssl-conf de Apache con SSL/TLS de nuestro repositorio 
cp ../conf/default-ssl.conf /etc/apache2/sites-available

# Habilitamos el virtual host que acabamos de configurar
a2ensite default-ssl.conf

# Habilitamos el módulo SSL en Apache.
sudo a2enmod ssl

# Copiamos el archivo de configuración de Apache para HTTP
cp ../conf/000-default.conf /etc/apache2/sites-available

# 1.5 Cómo consultar la fecha de caducidad del certificado
# openssl x509 -in /etc/ssl/certs/apache-selfsigned.crt -noout -dates

# Habilitamos el virtual host que acabamos de configurar.
sudo a2ensite default-ssl.conf

#Para que el servidor web Apache pueda hacer la redirección de HTTP a HTTPS es necesario habilitar el módulo rewrite en Apache.
sudo a2enmod rewrite

# Reiniciamos el servicio de Apache
sudo systemctl restart apache2

# Tenemos que agregar el DNS a nuestra máquina local
# sudo echo "3.230.202.96 practica-https.local" >> /etc/hosts
# sudo echo "3.230.202.96 practica-https.local" | tee /etc/hosts