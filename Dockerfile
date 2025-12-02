# Imagen base de PHP con Apache
FROM php:8.1-apache

# Instala extensiones necesarias
RUN apt-get update && apt-get install -y \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libpq-dev \
    libzip-dev \
    && docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql pdo_pgsql gd zip

# Habilitar mod_rewrite
RUN a2enmod rewrite

# Configurar Apache para que apunte al public/
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf \
    && sed -i 's|AllowOverride None|AllowOverride All|g' /etc/apache2/apache2.conf

# Copiar código de EspoCRM al contenedor
COPY . /var/www/html/

# Permisos (muy importante)
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Puerto expuesto
EXPOSE 80

# Iniciar Apache
CMD ["apache2-foreground"]

    
