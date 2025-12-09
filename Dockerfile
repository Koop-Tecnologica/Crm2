FROM php:8.2-apache

# Instalar dependencias necesarias para EspoCRM
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    libzip-dev \
    libicu-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libxml2-dev \
    && docker-php-ext-install intl zip pdo pdo_mysql gd

# Habilitar mod_rewrite
RUN a2enmod rewrite

# Copiar archivos del proyecto al contenedor
COPY . /var/www/html/

# Asegurar propietario correcto
RUN chown -R www-data:www-data /var/www/html

# Ajustar permisos para carpetas requeridas por EspoCRM
RUN find /var/www/html -type d -exec chmod 755 {} \;
RUN find /var/www/html -type f -exec chmod 644 {} \;

# Carpetas que deben tener permisos de escritura
RUN chmod -R 775 /var/www/html/data \
    && chmod -R 775 /var/www/html/custom \
    && chmod -R 775 /var/www/html/uploads \
    && chown -R www-data:www-data /var/www/html/data \
    && chown -R www-data:www-data /var/www/html/custom \
    && chown -R www-data:www-data /var/www/html/uploads

# Puerto
EXPOSE 80

CMD ["apache2-foreground"]

    
