# Dockerfile optimizado para EspoCRM en Render (PHP 8.2 + Apache)
FROM php:8.2-apache

# Evitar prompts de apt y actualizar
ENV DEBIAN_FRONTEND=noninteractive

# 1) Instalar dependencias necesarias y extensiones PHP
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      unzip \
      libpng-dev \
      libjpeg-dev \
      libpq-dev \
      libzip-dev \
      libexif-dev \
      git \
      procps && \
    docker-php-ext-configure gd --with-jpeg && \
    docker-php-ext-install -j$(nproc) pdo pdo_mysql pdo_pgsql gd zip exif && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 2) Ajustes de PHP (puedes cambiar valores si lo necesitas)
RUN { \
    echo "max_execution_time = 180"; \
    echo "max_input_time = 180"; \
    echo "memory_limit = 256M"; \
    echo "post_max_size = 20M"; \
    echo "upload_max_filesize = 20M"; \
} > /usr/local/etc/php/conf.d/custom.ini

# 3) Habilitar mod_rewrite de Apache
RUN a2enmod rewrite

# 4) Establecer directorio de trabajo
WORKDIR /var/www/html

# 5) Copiar el código de EspoCRM al contenedor
#    (si tu repo contiene muchos archivos grandes considera usar .dockerignore)
COPY . /var/www/html/

# 6) Crear carpeta de config si no existe y fijar permisos básicos
RUN mkdir -p /var/www/html/application/config && \
    chown -R www-data:www-data /var/www/html && \
    find /var/www/html -type d -exec chmod 755 {} \; && \
    find /var/www/html -type f -exec chmod 644 {} \; \
    && chmod -R 777 /var/www/html/data /var/www/html/application/config || true

# 7) Copiar entrypoint y hacerlo ejecutable
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 8) Exponer puerto
EXPOSE 80

# 9) Comando por defecto (entrypoint)
CMD ["/usr/local/bin/entrypoint.sh"]

