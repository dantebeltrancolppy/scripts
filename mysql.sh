#!/bin/bash

conectar_db() {
    # 1. Cargar variables del archivo .env
    if [ -f .env ]; then
        # Exporta las variables automáticamente para que estén disponibles
        export $(grep -v '^#' .env | xargs)
    else
        echo "❌ Error: No se encontró el archivo .env"
        exit 1
    fi

    # 2. Definir el entorno (Por defecto TEST si no se pasa argumento)
    # ${1:-TEST} significa: "Usa el primer argumento, si está vacío usa 'TEST'"
    # ${VAR^^} convierte a mayúsculas (bash 4.0+)
    ENV_SELECCIONADO="${1:-TEST}"
    ENV_UPPER="${ENV_SELECCIONADO^^}"

    echo "🔍 Configurando conexión para entorno: $ENV_UPPER..."

    # 3. Asignar variables locales según el entorno elegido
    if [ "$ENV_UPPER" == "PROD" ]; then
        HOST=$DB_HOST_PROD
        USER=$DB_USER_PROD
        PASS=$DB_PASSWORD_PROD
        DB=$DB_NAME_PROD
        COLOR="\033[1;31m" # Rojo para PROD (Alerta)
    elif [ "$ENV_UPPER" == "STAGING" ]; then
        HOST=$DB_HOST_STAGING
        USER=$DB_USER_STAGING
        PASS=$DB_PASSWORD_STAGING
        DB=$DB_NAME_STAGING
        COLOR="\033[1;33m" # Amarillo para STAGING
    elif [ "$ENV_UPPER" == "TEST" ]; then
        HOST=$DB_HOST_TEST
        USER=$DB_USER_TEST
        PASS=$DB_PASSWORD_TEST
        DB=$DB_NAME_TEST
        COLOR="\033[1;32m" # Verde para TEST
    else
        echo "❌ Error: Entorno '$ENV_SELECCIONADO' no válido. Usa: TEST, STAGING o PROD."
        exit 1
    fi

    # 4. Validar que las credenciales existan
    if [ -z "$HOST" ]; then
        echo "❌ Error: No se encontraron credenciales para $ENV_UPPER en el .env"
        exit 1
    fi

    # 5. Ejecutar la conexión interactiva
    # Reset de color
    NC='\033[0m' 
    
    echo -e "${COLOR}🚀 Conectando a $HOST ($DB)...${NC}"
    echo "-----------------------------------------------------"
    
    # Usamos 'export MYSQL_PWD' para evitar el warning de usar password en linea de comandos
    export MYSQL_PWD=$PASS
    
    # -A: No auto-rehash (hace que arranque más rápido si hay muchas tablas)
    # Se conecta y te deja en el prompt mysql>
    mysql -h "$HOST" -u "$USER" -D "$DB" -A

    # Limpiar variable de entorno por seguridad al salir
    unset MYSQL_PWD
    echo -e "\n👋 Sesión finalizada."
}
