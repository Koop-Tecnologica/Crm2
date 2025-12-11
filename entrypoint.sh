#!/bin/bash
set -e

CONFIG_DIR="/var/www/html/application/config"
CONFIG_FILE="$CONFIG_DIR/config.php"

# CRÍTICO: Debe ser 'pgsql' si usas PostgreSQL
DB_TYPE="pgsql"

# --- EJECUCIÓN DEL SCRIPT ---

# 1. Chequea si la configuración ya fue generada
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config.php no encontrado. Generando configuración de base de datos..."

    # 2. Creación del archivo config.php (inyección directa de variables de entorno)
    cat << EOF > "$CONFIG_FILE"
<?php
return array (
  'database' =>
  array (
    'driver' => '$DB_TYPE',
    'host' => '$DB_HOST',
    'port' => '$DB_PORT',
    'name' => '$DB_NAME',
    'user' => '$DB_USER',
    'password' => '$DB_PASSWORD',
  ),
  'setup' =>
  array (
    'adminUsername' => '$ADMIN_USER',
    'adminPassword' => '$ADMIN_PASSWORD',
    'defaultLanguage' => 'es_ES',
    'primaryUrl' => 'https://crm2-rd3k.onrender.com/',
  ),
  'isInstalled' => true,
);
EOF
    echo "Configuración generada exitosamente."
    
    # 3. CRÍTICO: Ejecutar el comando de instalación de EspoCRM para crear las tablas en la DB.
    echo "Ejecutando instalación de DB (creación de tablas)..."

    # Nota: Usamos la ruta /var/www/html/bin/command.php, que se encuentra en EspoCRM.
    /usr/local/bin/php /var/www/html/bin/command.php install --silent --user=$ADMIN_USER --password=$ADMIN_PASSWORD --language=es_ES
    
    if [ $? -ne 0 ]; then
        echo "Error FATAL: Falló la creación de tablas en la base de datos."
        # Permitimos que siga para que se vea el error en la web.
    else
        echo "Instalación de DB (tablas) completada exitosamente."
    fi

else
    echo "Config.php encontrado. Iniciando CRM..."
fi

# 4. Iniciar Apache en primer plano
exec apache2-foreground