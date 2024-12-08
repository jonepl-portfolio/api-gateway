#!/bin/bash

DEFAULT_SERVER_NAME="localhost"
SHARED_SECRET="/run/secrets/shared_secret"
WORKING_DIR="/etc/nginx/"

cd $WORKING_DIR

log_message() {
    local level="$1"
    local message="$2"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $message"
}

initialize_env_vars() {
  # Initial environment variables from docker secret file
  if [ -e "$SHARED_SECRET" ]; then
      log_message "INFO" "Setting environment variables for $SHARED_SECRET file"
      set -o allexport
      . "$SHARED_SECRET"
      set +o allexport
  else
      log_message "WARN" "No application configurations found."
  fi
}

check_env_variables() {
  log_message "INFO" "Checking if all required environment variables are set..."
  local required_env_vars=(
    SERVER_NAME
    DOMAIN
    API_SUBDOMAIN
    PORTAINER_SUBDOMAIN
    SSL_CERTIFICATE_BASE_DIR
    SELF_SIGN_CERTIFICATE_NAME
    SELF_SIGN_CERTIFICATE_KEY_NAME
    CA_SIGN_CERTIFICATE_NAME
    CA_SIGN_CERTIFICATE_KEY_NAME
  )

  for env_var in "${required_env_vars[@]}"; do
    if [[ -z "${!env_var}" ]]; then
      log_message "ERROR" "The environment variable $env_var is not defined"
      return 1
    fi
  done

  return 0
}

determine_certificate() {
  # Determine if self-signed or CA-signed certificate should be used
  SSL_CERTIFICATE_PATH="$SSL_CERTIFICATE_BASE_DIR/$DOMAIN/$CA_SIGN_CERTIFICATE_NAME"
  SSL_CERTIFICATE_KEY_PATH="$SSL_CERTIFICATE_BASE_DIR/$DOMAIN/$CA_SIGN_CERTIFICATE_KEY_NAME"

  if [ ! -f "$SSL_CERTIFICATE_PATH" ] || [ ! -f "$SSL_CERTIFICATE_KEY_PATH" ]; then
      log_message "INFO" "No CA-signed certificate or key found. Using self-signed certificate instead."
      SSL_CERTIFICATE_PATH="$SSL_CERTIFICATE_BASE_DIR/$DOMAIN/$SELF_SIGN_CERTIFICATE_NAME"
      SSL_CERTIFICATE_KEY_PATH="$SSL_CERTIFICATE_BASE_DIR/$DOMAIN/$SELF_SIGN_CERTIFICATE_KEY_NAME"
      create_self_signed_certificate $SSL_CERTIFICATE_PATH $SSL_CERTIFICATE_KEY_PATH
  fi

  log_message "INFO" "Sourcing ssl certificate: $SSL_CERTIFICATE_PATH" $SSL_CERTIFICATE_KEY_PATH
  export SSL_CERTIFICATE_PATH SSL_CERTIFICATE_KEY_PATH
}


create_self_signed_certificate() {
    local SSL_CERTIFICATE="$1"
    local SSL_CERTIFICATE_KEY="$2"

    # Check if the SSL_CERTIFICATE and SSL_CERTIFICATE_KEY are in the same directory
    if [ "$(dirname "$SSL_CERTIFICATE")" != "$(dirname "$SSL_CERTIFICATE_KEY")" ]; then
        log_message "ERROR" "SSL_CERTIFICATE and SSL_CERTIFICATE_KEY must be in the same directory"
        exit 1
    fi

    SSL_CERT_DIR="$(dirname "$SSL_CERTIFICATE")"
    log_message "INFO" "Creating self-signed certificate directory in $SSL_CERT_DIR"
    mkdir -p "$SSL_CERT_DIR" || { log_message "ERROR" "Could not create directory $SSL_CERT_DIR"; exit 1; }

    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout $SSL_CERTIFICATE_KEY \
        -out $SSL_CERTIFICATE \
        -subj "/CN=localhost"
}


initialize_env_vars

check_env_variables

# Use default servername
if [ -z "$DOMAIN" ]; then
    log_message "INFO" "DOMAIN environment variable is not set or empty. Using default value $DEFAULT_SERVER_NAME"
    export DOMAIN=$DEFAULT_SERVER_NAME
fi

determine_certificate

# Replace environment variables in nginx.conf template
envsubst '${DOMAIN},${SSL_CERTIFICATE_PATH},${SSL_CERTIFICATE_KEY_PATH},${API_SUBDOMAIN},${PORTAINER_SUBDOMAIN}' < nginx.conf.template > nginx.conf

log_message "DEBUG" "DOMAIN: ${DOMAIN}"
log_message "DEBUG" "API_SUBDOMAIN: ${API_SUBDOMAIN}"
log_message "DEBUG" "SSL_CERTIFICATE_PATH: ${SSL_CERTIFICATE_PATH}"
log_message "DEBUG" "SSL_CERTIFICATE_KEY_PATH: ${SSL_CERTIFICATE_KEY_PATH}"

# cat nginx.conf

log_message "INFO" "Starting nginx server..."
nginx -g 'daemon off;'