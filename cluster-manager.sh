#!/bin/bash
_SCRIPT_PATH="${BASH_SOURCE[0]}"

SCRIPTS_FOLDER="$( cd -- "$( dirname -- "$_SCRIPT_PATH" )" &> /dev/null && pwd )"
change_cluster() {

    local ENV_FILE="$SCRIPTS_FOLDER/.env"
    echo $ENV_FILE

    if [ ! -f "$ENV_FILE" ]; then
        echo "❌ Error: .env not found"
        return 1
    fi

    set -a
    source "$ENV_FILE"
    set +a


    local env_selected=$1

    if [ -z "$env_selected" ]; then
    echo "Usage: $0 <env_selected> [prod|stg|test]"
    return 1
    fi
    case "$env_selected" in
        prod)
            cluster_name="PROD-N-EKS-cluster"
            ;;
        test)
            cluster_name="TEST-N-EKS-cluster"
            ;;
        stg)
            cluster_name="STG-N-EKS-cluster"
            ;;
        *)
            echo "❌ Error: Unexpected environment." >&2
            echo "Allowed options: prod, test, stg" >&2
            return 1
            ;;
    esac

    export AWS_PROFILE=$env_selected
    echo $AWS_PROFILE
    echo "Logging in to AWS SSO with profile: $AWS_PROFILE"
    aws sso login --profile "$AWS_PROFILE"

    echo "Switching kubectl context to cluster: $cluster_name"
    aws eks update-kubeconfig --region "$AWS_DEFAULT_REGION" --name "$cluster_name" --profile $AWS_PROFILE

    kubectl get nodes
}