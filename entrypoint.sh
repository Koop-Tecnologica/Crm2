#!/bin/bash
set -e

CONFIG_DIR="/var/www/html/application/config"
CONFIG_FILE="$CONFIG_DIR/config.php"

# --- DEFINICIÓN DE VARIABLES ---
# Usamos las variables de entorno de Render
DB_TYPE="pgsql" # CRÍTICO: Debe ser 'pgsql' si usas PostgreSQL

# --- EJECUCIÓN DEL SCRIPT ---

# 1. Chequea si la configuración ya fue generada
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config.php no encontrado. Generando configuración de base de datos..."

    # 2. Creación del archivo config.php (inyección directa de variables de entorno)
    # Esto elimina la dependencia del cli.php de EspoCRM que estaba fallando.
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

    # 3. Borrar el caché de EspoCRM para que cargue la nueva configuración
    echo "Configuración generada. Limpiando caché..."
    /usr/local/bin/php /var/www/html/bin/command.php cache:clear

    if [ $? -ne 0 ]; then
        echo "Advertencia: Falló la limpieza de caché, pero la configuración fue escrita. Intentando continuar."
    else
        echo "Configuración y limpieza de caché completada exitosamente."
    fi
else
    echo "Config.php encontrado. Iniciando CRM..."
fi

# 4. Iniciar Apache en primer plano
exec apache2-foreground