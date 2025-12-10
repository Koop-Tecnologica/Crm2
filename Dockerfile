# Imagen base de PHP 8.2 con Apache
FROM php:8.2-apache

# ----------------------------------------------------------------------------------
# 1. INSTALACIÓN DE DEPENDENCIAS (Solución Unificada para estabilidad)
# ----------------------------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libpq-dev \
    libzip-dev \
    libexif-dev && \
    \
    docker-php-ext-configure gd --with-jpeg && \
    docker-php-ext-install pdo pdo_mysql pdo_pgsql gd zip exif && \
    \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------------------------------
# 1.5. Configurar php.ini para optimizar el rendimiento
RUN echo 'max_execution_time = 180' >> /usr/local/etc/php/conf.d/custom.ini \
    && echo 'max_input_time = 180' >> /usr/local/etc/php/conf.d/custom.ini \
    && echo 'memory_limit = 256M' >> /usr/local/etc/php/conf.d/custom.ini \
    && echo 'post_max_size = 20M' >> /usr/local/etc/php/conf.d/custom.ini \
    && echo 'upload_max_filesize = 20M' >> /usr/local/etc/php/conf.d/custom.ini

# 2. Habilitar mod_rewrite
RUN a2enmod rewrite

# 3. Copiar código de EspoCRM al contenedor
COPY . /var/www/html/

# 4. Configurar Apache para apuntar a la RAÍZ DEL PROYECTO (/var/www/html)
RUN echo '<VirtualHost *:80>\n' \
    '    DocumentRoot /var/www/html\n' \
    '    <Directory /var/www/html>\n' \
    '        AllowOverride All\n' \
    '        Require all granted\n' \
    '    </Directory>\n' \
    '    ErrorLog ${APACHE_LOG_DIR}/error.log\n' \
    '    CustomLog ${APACHE_LOG_DIR}/access.log combined\n' \
    '    </VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# ----------------------------------------------------------------------------------
# 5. PERMISOS (Bloque que resuelve todos los problemas de persistencia y build)
# ----------------------------------------------------------------------------------

# 5a. Permisos generales: Propiedad para www-data y permisos estándar
RUN chown -R www-data:www-data /var/www/html && \
    find /var/www/html -type d -exec chmod 755 {} \; && \
    find /var/www/html -type f -exec chmod 644 {} \;

# 5b. CREACIÓN y CORRECCIÓN CRÍTICA DE ESPO-CRM: 
# Crea la carpeta 'config' y luego aplica los permisos 775 a 'data' y 'config'.
RUN mkdir -p /var/www/html/application/config && \
    chmod -R 775 /var/www/html/data && \
    chmod -R 775 /var/www/html/application/config

# ----------------------------------------------------------------------------------

# 6. Puerto expuesto
EXPOSE 80

# 7. Iniciar Apache en primer plano
CMD ["apache2-foreground"]