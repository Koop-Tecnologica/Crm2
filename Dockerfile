# Imagen base de PHP 8.2 con Apache
FROM php:8.2-apache

# ----------------------------------------------------------------------------------
# 1. INSTALACIÓN DE DEPENDENCIAS
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
# 2. Configuración php.ini
# ----------------------------------------------------------------------------------
RUN echo 'max_execution_time = 180' >> /usr/local/etc/php/conf.d/custom.ini \
    && echo 'max_input_time = 180' >> /usr/local/etc/php/conf.d/custom.ini \
    && echo 'memory_limit = 256M' >> /usr/local/etc/php/conf.d/custom.ini \
    && echo 'post_max_size = 20M' >> /usr/local/etc/php/conf.d/custom.ini \
    && echo 'upload_max_filesize = 20M' >> /usr/local/etc/php/conf.d/custom.ini

# 3. Habilitar mod_rewrite
RUN a2enmod rewrite

# ----------------------------------------------------------------------------------
# 4. Copiar código de EspoCRM al contenedor
# ----------------------------------------------------------------------------------
COPY . /var/www/html/

# ----------------------------------------------------------------------------------
# 5. CONFIGURACIÓN DE APACHE
# ----------------------------------------------------------------------------------
RUN printf '<VirtualHost *:80>\n' > /etc/apache2/sites-available/000-default.conf && \
    printf '    DocumentRoot /var/www/html\n' >> /etc/apache2/sites-available/000-default.conf && \
    printf '    <Directory /var/www/html>\n' >> /etc/apache2/sites-available/000-default.conf && \
    printf '        AllowOverride All\n' >> /etc/apache2/sites-available/000-default.conf && \
    printf '        Require all granted\n' >> /etc/apache2/sites-available/000-default.conf && \
    printf '    </Directory>\n' >> /etc/apache2/sites-available/000-default.conf && \
    printf '    ErrorLog ${APACHE_LOG_DIR}/error.log\n' >> /etc/apache2/sites-available/000-default.conf && \
    printf '    CustomLog ${APACHE_LOG_DIR}/access.log combined\n' >> /etc/apache2/sites-available/000-default.conf && \
    printf '</VirtualHost>\n' >> /etc/apache2/sites-available/000-default.conf

# ----------------------------------------------------------------------------------
# 6. PERMISOS PARA ESPOSCRM Y CARPETAS CRÍTICAS
# ----------------------------------------------------------------------------------
RUN chown -R www-data:www-data /var/www/html && \
    find /var/www/html -type d -exec chmod 755 {} \; && \
    find /var/www/html -type f -exec chmod 644 {} \; && \
    mkdir -p /var/www/html/application/config && \
    chmod -R 755 /var/www/html/data && \
    chmod -R 755 /var/www/html/application/config

# ----------------------------------------------------------------------------------
# 7. Exponer puerto 80 y configurar entrypoint
# ----------------------------------------------------------------------------------
EXPOSE 80

# Copiar el script entrypoint y darle permisos de ejecución
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Definir el entrypoint
CMD ["/usr/local/bin/entrypoint.sh"]
