# Imagen base de PHP 8.2 con Apache (CORRECCIÓN APLICADA AQUÍ)
FROM php:8.2-apache

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
COPY . /var/www/html/

# 4. Configurar Apache para apuntar a la RAÍZ DEL PROYECTO (/var/www/html)
# Esto permite que tu archivo .htaccess funcione para redirigir a 'public'.
RUN echo '<VirtualHost *:80>\n' \
    '    DocumentRoot /var/www/html\n' \
    '    <Directory /var/www/html>\n' \
    '        AllowOverride All\n' \
    '        Require all granted\n' \
    '    </Directory>\n' \
    '    ErrorLog ${APACHE_LOG_DIR}/error.log\n' \
    '    CustomLog ${APACHE_LOG_DIR}/access.log combined\n' \
    '</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# 5. Permisos
# Establecer el propietario www-data y aplicar permisos seguros
RUN chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && find /var/www/html -type f -exec chmod 644 {} \;

# 6. Puerto expuesto
EXPOSE 80

# 7. Iniciar Apache en primer plano
CMD ["apache2-foreground"]
    
