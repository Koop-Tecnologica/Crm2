FROM php:8.2-apache

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    libpq-dev \
    unzip \
    git \
    && docker-php-ext-install pdo pdo_pgsql

# Habilitar mod_rewrite
RUN a2enmod rewrite

# Establecer directorio de trabajo
WORKDIR /var/www/html

# Copiar proyecto
COPY . /var/www/html/

# Crear las carpetas que sí usa EspoCRM
RUN mkdir -p /var/www/html/data \
    && mkdir -p /var/www/html/custom \
    && mkdir -p /var/www/html/uploads

# Permisos correctos
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/data \
    && chmod -R 775 /var/www/html/custom \
    && chmod -R 775 /var/www/html/uploads

# Evitar volver al instalador si Render borra config-internal.php
# (no elimina nada, solo previene errores)
RUN touch /var/www/html/data/config-internal.php

EXPOSE 80

CMD ["apache2-foreground"]

