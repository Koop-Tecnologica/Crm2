FROM php:8.1-apache

# Instalar extensiones necesarias para EspoCRM
RUN apt-get update && apt-get install -y \
    libzip-dev unzip libpng-dev libonig-dev mariadb-client \
    && docker-php-ext-install pdo pdo_mysql zip gd

# Habilitar mod_rewrite
RUN a2enmod rewrite

# Configurar Apache para que apunte a /public
RUN sed -i 's|/var/www/html|/var/www/html/public|' /etc/apache2/sites-available/000-default.conf

# Permitir .htaccess
RUN sed -i 's|AllowOverride None|AllowOverride All|' /etc/apache2/apache2.conf

# Copiar archivos del proyecto
COPY . /var/www/html/

# Asignar permisos correctos (IMPORTANTE para evitar 403)
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 755 /var/www/html/public

# Exponer puerto
EXPOSE 80

CMD ["apache2-foreground"]

