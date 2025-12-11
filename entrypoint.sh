#!/bin/bash
set -e

CONFIG_DIR="/var/www/html/application/config"
CONFIG_FILE="$CONFIG_DIR/config.php"

# --- EJECUCIÓN DEL SCRIPT ---

# 1. Chequea si la configuración ya fue generada
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config.php no encontrado. Ejecutando instalación de EspoCRM por CLI..."

    # 2. Construir el comando usando eval para forzar la inyección de variables
    INSTALL_COMMAND="/usr/local/bin/php /var/www/html/install/cli.php"
    
    # Parámetros para la DB (deben funcionar)
    DB_PARAMS="--database-host=$DB_HOST --database-user=$DB_USER --database-password=$DB_PASSWORD --database-name=$DB_NAME --database-type=pgsql"
    
    # Parámetros CRÍTICOS del administrador (usando -a, -p cortos para compatibilidad forzada)
    ADMIN_PARAMS="--admin-user=$ADMIN_USER --admin-password=$ADMIN_PASSWORD --admin-email=admin@example.com"
    
    # Parámetros Generales
    GENERAL_PARAMS="--silent=1 --language=es_ES --site-url=https://crm2-rd3k.onrender.com"
    
    # Ejecución de la instalación
    eval "$INSTALL_COMMAND $DB_PARAMS $ADMIN_PARAMS $GENERAL_PARAMS"

    # $? captura el código de salida del comando anterior (la instalación PHP)
    if [ $? -ne 0 ]; then
        echo "Error: Falló la instalación por CLI (código de salida $?). Por favor, revisa las variables DB_* y ADMIN_*"
        # El script sigue para iniciar Apache y exponer el error en los logs.
    else
        echo "Instalación CLI completada exitosamente."
    fi
else
    echo "Config.php encontrado. Iniciando CRM..."
fi

# 3. Iniciar Apache en primer plano
exec apache2-foreground