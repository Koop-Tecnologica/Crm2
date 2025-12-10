FROM php:8.2-apache

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    libpq-dev \
    unzip \
    git \
    && docker-php-ext-install pdo pdo_pgsql

# Habilitar mod_rewrite
RUN a2enmod rewrite

# Establecer el directorio de trabajo
WORKDIR /var/www/html

# Copiar código de EspoCRM al contenedor
COPY . /var/www/html/

# Asegurar permisos correctos para evitar que vuelva al instalador
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html \
    && chmod -R 775 /var/www/html/data \
    && chmod -R 775 /var/www/html/custom \
    && chmod -R 775 /var/www/html/application \
    && chmod -R 775 /var/www/html/extension \
    && chmod -R 775 /var/www/html/api \
    && chmod -R 775 /var/www/html/client

# Evitar que Render cachee el instalador
RUN rm -f /var/www/html/data/config-internal.php || true

# Configurar Apache
RUN printf "<Directory /var/www/html>\n\
    AllowOverride All\n\
</Directory>\n" > /etc/apache2/conf-available/espo.conf \
    && a2enconf espo

EXPOSE 80

CMD ["apache2-foreground"]
