#!/bin/bash

# ==============================================================================
# 1. AUTO-DETECT PATH
# ==============================================================================
# Detects where this file is saved to look for the .env in the same folder
_SCRIPT_PATH="${BASH_SOURCE[0]}"
PROJECT_ROOT="$( cd -- "$( dirname -- "$_SCRIPT_PATH" )" &> /dev/null && pwd )"

# ==============================================================================
# 2. UTILITY FUNCTIONS
# ==============================================================================

load_credentials() {
    local ENV_FILE="$PROJECT_ROOT/.env"

    if [ ! -f "$ENV_FILE" ]; then
        echo "❌ Error: .env file not found at $PROJECT_ROOT"
        echo "   Please create one using .env.example as a template."
        return 1
    fi

    echo "🔓 Loading credentials from .env..."
    # 'set -a' automatically exports read variables so the 'aws' command can see them
    set -a
    source "$ENV_FILE"
    set +a

    if [ -z "$AWS_ACCESS_KEY_ID" ]; then
        echo "⚠️  Warning: AWS_ACCESS_KEY_ID not found in .env"
    fi
}

# ==============================================================================
# 3. MAIN FUNCTION
# ==============================================================================

function download_colppy_configs() {
    # Load environment before doing anything
    load_credentials

    local REPO_NAME="colppy-app"
    local BUCKET_BASE="s3://colppy-environments"
    local ENV_FOLDER=""

    # Allow passing the environment as an argument
    if [ -n "$1" ]; then
        case "$1" in
            develop|release|master) ENV_FOLDER="$1";;
            *) echo "Error: Invalid environment '$1'. Use: develop, release, master."; return 1;;
        esac
    else
        echo "Select Environment:"
        echo "1) develop"
        echo "2) release"
        echo "3) master"
        read -p "Option: " OPCION

        case $OPCION in
            1) ENV_FOLDER="develop";;
            2) ENV_FOLDER="release";;
            3) ENV_FOLDER="master";;
            *) echo "Invalid option"; return 1;;
        esac
    fi

    # UPDATE: Directory name now includes Repo Name and Environment to avoid collisions
    local OUTPUT_DIR="./configs_${REPO_NAME}_${ENV_FOLDER}"
    mkdir -p "$OUTPUT_DIR"

    echo "⬇️  Downloading from: $BUCKET_BASE/$REPO_NAME/$ENV_FOLDER/"
    echo "📂 Target Directory: $OUTPUT_DIR"

    # Download specific configuration files
    aws s3 cp "$BUCKET_BASE/$REPO_NAME/$ENV_FOLDER/env" "$OUTPUT_DIR/.env"
    aws s3 cp "$BUCKET_BASE/$REPO_NAME/$ENV_FOLDER/serviceAWS.php" "$OUTPUT_DIR/service.php"
    aws s3 cp "$BUCKET_BASE/$REPO_NAME/$ENV_FOLDER/globalesAWS.js" "$OUTPUT_DIR/globales.js"
    aws s3 cp "$BUCKET_BASE/$REPO_NAME/$ENV_FOLDER/paramAWS.php" "$OUTPUT_DIR/param.php"
    aws s3 cp "$BUCKET_BASE/$REPO_NAME/$ENV_FOLDER/produccionAWS.php" "$OUTPUT_DIR/produccion.php"
    
    # Download index.php from the bucket root (special logic)
    aws s3 cp "$BUCKET_BASE/$REPO_NAME/index.php" "$OUTPUT_DIR/index.php"

    echo "✅ Files downloaded successfully to: $OUTPUT_DIR"
}