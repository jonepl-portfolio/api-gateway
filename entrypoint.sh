#!/bin/bash

DEFAULT_SERVER_NAME="localhost"
ENV_CONFIG="/run/secrets/app_config"
WORKING_DIR="/etc/nginx/"

cd $WORKING_DIR

log_message() {
    local level="$1"
    local message="$2"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $message"
}

# Initial environment variables from .env file
if [ -e $ENV_CONFIG ]; then
    log_message "INFO" "Setting environment variables for $ENV_CONFIG file"
    set -o allexport
    . $ENV_CONFIG
    set +o allexport
else
    log_message "INFO" "No $ENV_CONFIG found."
fi

# Use default servername
if [ -z "$DOMAIN" ]; then
    log_message "INFO" "DOMAIN environment variable is not set or empty. Using default value $DEFAULT_SERVER_NAME"
    export DOMAIN=$DEFAULT_SERVER_NAME
fi

# Determine if self-signed or CA-signed certificate should be used
SSL_CERTIFICATE_PATH="$SSL_CERTIFICATE_BASE_DIR/$DOMAIN/$CA_SIGN_CERTIFICATE_NAME"
SSL_CERTIFICATE_KEY_PATH="$SSL_CERTIFICATE_BASE_DIR/$DOMAIN/$CA_SIGN_CERTIFICATE_KEY_NAME"

if [ ! -f "$SSL_CERTIFICATE_PATH" ] || [ ! -f "$SSL_CERTIFICATE_KEY_PATH" ]; then
    log_message "INFO" "No CA-signed certificate or key found. Using self-signed certificate instead."
    SSL_CERTIFICATE_PATH="$SSL_CERTIFICATE_BASE_DIR/$DOMAIN/$SELF_SIGN_CERTIFICATE_NAME"
    SSL_CERTIFICATE_KEY_PATH="$SSL_CERTIFICATE_BASE_DIR/$DOMAIN/$SELF_SIGN_CERTIFICATE_KEY_NAME"
fi

log_message "INFO" "Sourcing ssl certificate: $SSL_CERTIFICATE_PATH" $SSL_CERTIFICATE_KEY_PATH
export SSL_CERTIFICATE_PATH SSL_CERTIFICATE_KEY_PATH


# Replace environment variables in nginx.conf template
envsubst '${DOMAIN},${SSL_CERTIFICATE_PATH},${SSL_CERTIFICATE_KEY_PATH},${API_SUBDOMAIN},${PORTAINER_SUBDOMAIN}' < nginx.conf.template > nginx.conf

log_message "DEBUG" "DOMAIN: ${DOMAIN}"
log_message "DEBUG" "API_SUBDOMAIN: ${API_SUBDOMAIN}"
log_message "DEBUG" "SSL_CERTIFICATE_PATH: ${SSL_CERTIFICATE_PATH}"
log_message "DEBUG" "SSL_CERTIFICATE_KEY_PATH: ${SSL_CERTIFICATE_KEY_PATH}"

cat nginx.conf

log_message "INFO" "Starting nginx server..."
nginx -g 'daemon off;'