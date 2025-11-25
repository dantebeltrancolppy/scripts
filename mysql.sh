#!/bin/bash

# ==============================================================================
# 1. AUTO-DETECCIÓN DE LA RUTA (La magia ocurre aquí)
# ==============================================================================
# Esto se ejecuta una sola vez, cuando haces 'source conectar.sh'.
# Detecta dónde está guardado este archivo y guarda la ruta en una variable.
# ------------------------------------------------------------------------------

# Obtiene la ruta relativa del script actual (mientras se hace source)
_SCRIPT_PATH="${BASH_SOURCE[0]}"

# Resuelve la ruta absoluta del directorio donde vive este script
# (Entra al directorio, hace pwd y guarda el resultado)
DB_PROJECT_ROOT="$( cd -- "$( dirname -- "$_SCRIPT_PATH" )" &> /dev/null && pwd )"

# ==============================================================================
# 2. LA FUNCIÓN
# ==============================================================================

conectar_db() {
    # Usamos la variable que calculamos arriba automágicamente
    local ENV_FILE="$DB_PROJECT_ROOT/.env"

    # --- A. Validación del .env ---
    if [ ! -f "$ENV_FILE" ]; then
        echo "❌ Error CRÍTICO: No se encuentra el archivo .env"
        echo "   -> Buscando en: $ENV_FILE"
        echo "   -> Asegúrate de que el .env esté en la misma carpeta que este script."
        return 1
    fi

    # --- B. Cargar variables (Scope local para no ensuciar la terminal) ---
    # Usamos set -a para exportar automáticamente las variables leídas
    set -a
    source "$ENV_FILE"
    set +a

    # --- C. Definir Entorno ---
    local ENV_SELECCIONADO="${1:-TEST}"
    local ENV_UPPER="${ENV_SELECCIONADO^^}"

    echo "🔍 Configurando conexión para entorno: $ENV_UPPER..."

    # Variables temporales para la conexión
    local HOST=""
    local USER=""
    local PASS=""
    local DB=""
    local COLOR=""

    if [ "$ENV_UPPER" == "PROD" ]; then
        HOST="$DB_HOST_PROD"
        USER="$DB_USER_PROD"
        PASS="$DB_PASSWORD_PROD"
        DB="$DB_NAME_PROD"
        COLOR="\033[1;31m" # Rojo
    elif [ "$ENV_UPPER" == "STAGING" ]; then
        HOST="$DB_HOST_STAGING"
        USER="$DB_USER_STAGING"
        PASS="$DB_PASSWORD_STAGING"
        DB="$DB_NAME_STAGING"
        COLOR="\033[1;33m" # Amarillo
    elif [ "$ENV_UPPER" == "TEST" ]; then
        HOST="$DB_HOST_TEST"
        USER="$DB_USER_TEST"
        PASS="$DB_PASSWORD_TEST"
        DB="$DB_NAME_TEST"
        COLOR="\033[1;32m" # Verde
    else
        echo "❌ Error: Entorno '$ENV_SELECCIONADO' no válido."
        return 1
    fi

    # --- D. Validación final de credenciales ---
    if [ -z "$HOST" ]; then
        echo "❌ Error: Faltan credenciales para $ENV_UPPER en el .env"
        return 1
    fi

    # --- E. Conexión ---
    local NC='\033[0m' # No Color
    echo -e "${COLOR}🚀 Conectando a $HOST ($DB)...${NC}"
    
    # Exportamos la contraseña SOLO para este comando y la borramos inmediatamente
    export MYSQL_PWD="$PASS"
    
    mysql -h "$HOST" -u "$USER" -D "$DB" -A
    
    # Limpieza de seguridad
    unset MYSQL_PWD
    echo -e "\n👋 Sesión finalizada."
}