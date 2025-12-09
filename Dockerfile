FROM php:8.2-apache

# Instalar dependencias
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

RUN a2enmod rewrite

# Copiar proyecto
COPY . /var/www/html/

# Crear carpetas necesarias SI NO EXISTEN
RUN mkdir -p /var/www/html/data \
    && mkdir -p /var/www/html/custom \
    && mkdir -p /var/www/html/uploads

# Propietario correcto
RUN chown -R www-data:www-data /var/www/html

# Permisos generales
RUN find /var/www/html -type d -exec chmod 755 {} \;
RUN find /var/www/html -type f -exec chmod 644 {} \;

# Permisos especiales para carpetas de escritura
RUN chmod -R 775 /var/www/html/data \
    && chmod -R 775 /var/www/html/custom \
    && chmod -R 775 /var/www/html/uploads \
    && chown -R www-data:www-data /var/www/html/data \
    && chown -R www-data:www-data /var/www/html/custom \
    && chown -R www-data:www-data /var/www/html/uploads

EXPOSE 80

CMD ["apache2-foreground"]
