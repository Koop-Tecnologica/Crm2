#!/bin/bash
set -e

CONFIG_DIR="/var/www/html/application/config"
CONFIG_FILE="$CONFIG_DIR/config.php"

# --- EJECUCIÓN DEL SCRIPT ---

# 1. Chequea si la configuración ya fue generada
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config.php no encontrado. Ejecutando instalación de EspoCRM por CLI..."

    # 2. Comando CLI para instalación silenciosa (usa las variables de entorno de Render)
    # Importante: Esto asume que estás usando MySQL. Si usas PostgreSQL, cambia --database-type
    /usr/local/bin/php /var/www/html/install/cli.php \
        --silent=1 \
        --language=es_ES \
        --database-host=$DB_HOST \
        --database-user=$DB_USER \
        --database-password=$DB_PASSWORD \
        --database-name=$DB_NAME \
        --database-type=pgsql \
        --site-url=https:https://crm2-rd3k.onrender.com \
        --admin-user=$ADMIN_USER \
        --admin-password=$ADMIN_PASSWORD \
        --admin-email=admin@example.com

    if [ $? -ne 0 ]; then
        echo "Error: Falló la instalación por CLI. Revisa las variables DB_* y ADMIN_*"
        # El script continuará para intentar iniciar Apache y mostrar logs si hay fallos.
    else
        echo "Instalación CLI completada exitosamente."
    fi
else
    echo "Config.php encontrado. Iniciando CRM..."
fi

# 3. Iniciar Apache en primer plano
exec apache2-foreground