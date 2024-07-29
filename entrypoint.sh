#!/bin/bash

DEFAULT_SERVER_NAME="localhost"
ENV_CONFIG="/run/secrets/app_config"
WORKING_DIR="/etc/nginx/"

cd $WORKING_DIR

# Initial environment variables from .env file
if [ -e $ENV_CONFIG ]; then
    echo "Setting environment variables for $ENV_CONFIG file"
    set -o allexport
    . $ENV_CONFIG
    set +o allexport
else
    echo "No $ENV_CONFIG found."
fi

# Use default servername
if [ -z "$SERVER_NAME" ]; then
    echo "SERVER_NAME environment variable is not set or empty. Using default value $DEFAULT_SERVER_NAME"
    export SERVER_NAME=$DEFAULT_SERVER_NAME
    exit 1
fi


# Create nginx.conf with envionrment variable substitutions
# export $SERVER_NAME

envsubst '${SERVER_NAME},${DOMAIN},${SSL_CERTIFICATE_NAME},${SSL_CERTIFICATE_KEY_NAME},${API_SUBDOMAIN},${PORTAINER_SUBDOMAIN}' < nginx.conf.template > nginx.conf

echo "SERVER_NAME: ${SERVER_NAME}"
echo "SSL_CERTIFICATE_NAME: ${SSL_CERTIFICATE_NAME}"
echo "SSL_CERTIFICATE_KEY_NAME: ${SSL_CERTIFICATE_KEY_NAME}"
echo "API_SUBDOMAIN: ${API_SUBDOMAIN}"

cat nginx.conf

echo "Starting nginx server..."
nginx -g 'daemon off;'