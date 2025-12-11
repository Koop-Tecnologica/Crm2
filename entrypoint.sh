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

    # 2. Creación del archivo config.php (inyección directa de variables de entorno de Render)
    # Esto garantiza que el driver 'pgsql' y los datos de conexión se escriban correctamente.
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
    
    # 3. CRÍTICO: Inicializar la base de datos usando 'repair --silent'
    # Este comando crea las tablas si el config.php ya existe, que es lo que necesitamos.
    echo "Ejecutando inicialización de DB (repair --silent)..."
    
    /usr/local/bin/php /var/www/html/bin/command repair --silent

    if [ $? -ne 0 ]; then
        echo "Error FATAL: Falló la inicialización de la base de datos (repair). Revisa la ruta de 'bin/command'."
    else
        echo "Inicialización de DB (tablas) completada exitosamente."
    fi

else
    echo "Config.php encontrado. Iniciando CRM..."
fi

# 4. Iniciar Apache en primer plano
exec apache2-foreground