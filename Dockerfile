# Imagen base de PHP 8.1 con Apache
FROM php:8.1-apache

# 1. Instala extensiones necesarias
RUN apt-get update && apt-get install -y \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libpq-dev \
    libzip-dev \
    && docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql pdo_pgsql gd zip \
    # Limpiar caché para reducir el tamaño de la imagen
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. Habilitar mod_rewrite
RUN a2enmod rewrite

# 3. Copiar código de EspoCRM al contenedor
# Copia todo tu repositorio a /var/www/html/
COPY . /var/www/html/

# 4. Configurar Apache para que apunte a la carpeta 'public/'
# y habilitar el uso de archivos .htaccess
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf \
    && sed -i 's|AllowOverride None|AllowOverride All|g' /etc/apache2/apache2.conf

# 5. Permisos (CORRECCIÓN CLAVE para el 403 Forbidden)
# Establecer el propietario www-data y aplicar permisos seguros:
# Directorios: 755 (Lectura/Escritura/Ejecución)
# Archivos: 644 (Solo Lectura)
RUN chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && find /var/www/html -type f -exec chmod 644 {} \;

# 6. Puerto expuesto
EXPOSE 80

# 7. Iniciar Apache en primer plano
CMD ["apache2-foreground"]
    
