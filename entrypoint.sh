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

    # 2. Creación del archivo config.php (inyección directa)
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
    echo "Configuración de DB (config.php) generada exitosamente."

    # 3. ¡SOLUCIÓN CRÍTICA DE PERMISOS! 
    # Asegura que www-data pueda leer el archivo recién creado.
    echo "Ajustando permisos de configuración para www-data..."
    chown -R www-data:www-data "$CONFIG_DIR"
    chmod -R 777 "$CONFIG_DIR"
    
    # 4. Inicializar la base de datos
    echo "Ejecutando inicialización de DB (repair --silent)..."
    
    # Este comando ahora debería poder leer el config.php
    /usr/local/bin/php /var/www/html/bin/command repair --silent

    if [ $? -ne 0 ]; then
        echo "Error FATAL: Falló la inicialización de la base de datos (repair). Si esto persiste, la ruta 'bin/command' es incorrecta."
    else
        echo "Inicialización de DB (tablas) completada exitosamente."
    fi

else
    echo "Config.php encontrado. Iniciando CRM..."
fi

# 5. Iniciar Apache en primer plano
exec apache2-foreground