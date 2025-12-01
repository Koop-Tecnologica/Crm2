FROM php:8.2-apache

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    unzip \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Configuración de GD para PHP 8.x
RUN docker-php-ext-configure gd \
    --with-jpeg=/usr/include \
    --with-freetype=/usr/include

# Instalar extensiones PHP necesarias para EspoCRM
RUN docker-php-ext-install \
    gd \
    zip \
    mbstring \
    pdo \
    pdo_mysql \
    pdo_pgsql

# Copiar todos los archivos del proyecto al contenedor
COPY . /var/www/html

# Dar permisos de escritura
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

EXPOSE 80
