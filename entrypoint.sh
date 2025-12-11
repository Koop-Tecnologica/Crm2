#!/bin/bash
set -e

CONFIG_DIR="/var/www/html/application/config"
CONFIG_FILE="$CONFIG_DIR/config.php"

# --- EJECUCIÓN DEL SCRIPT ---

# 1. Chequea si la configuración ya fue generada
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config.php no encontrado. Ejecutando instalación de EspoCRM por CLI..."

    # 2. Comando CLI en UNA SOLA LÍNEA para evitar el error 'The option [-s] is required.'
    # ¡Las variables ($DB_HOST, etc.) SÍ están aquí, pasadas como argumentos!
    /usr/local/bin/php /var/www/html/install/cli.php --silent=1 --language=es_ES --database-host=$DB_HOST --database-user=$DB_USER --database-password=$DB_PASSWORD --database-name=$DB_NAME --database-type=pgsql --site-url=https://crm2-rd3k.onrender.com --admin-user=$ADMIN_USER --admin-password=$ADMIN_PASSWORD --admin-email=admin@example.com

    # $? captura el código de salida del comando anterior (la instalación PHP)
    if [ $? -ne 0 ]; then
        echo "Error: Falló la instalación por CLI (código de salida $?). Revisa las variables DB_* y ADMIN_*"
        # El script sigue para iniciar Apache y exponer el error en los logs.
    else
        echo "Instalación CLI completada exitosamente."
    fi
else
    echo "Config.php encontrado. Iniciando CRM..."
fi

# 3. Iniciar Apache en primer plano
exec apache2-foreground