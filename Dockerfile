FROM php:8.2-apache

# Instalar extensiones necesarias
RUN apt-get update && apt-get install -y \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libonig-dev \
    libxml2-dev \
    libpq-dev \
    && docker-php-ext-install pdo pdo_mysql pdo_pgsql gd mbstring zip

# Habilitar mod_rewrite
RUN a2enmod rewrite

# Copiar proyecto al contenedor
COPY . /var/www/html/

# Permisos
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 775 /var/www/html

# Puerto
EXPOSE 80

# Comando final
CMD ["apache2-foreground"]
