# Use a specific version of the Nginx base image
FROM nginx:1.25.5

# Install bash
RUN apt-get update && apt-get install -y bash

# Copy the nginx.conf template to the container
COPY ../nginx/nginx.conf.template /etc/nginx/nginx.conf.template

# Copy the entrypoint script to the container
COPY ../nginx/entrypoint.sh /etc/nginx/entrypoint.sh
RUN chmod +x /etc/nginx/entrypoint.sh

# Create a directory for the self-signed certificate
RUN mkdir -p /etc/letsencrypt/live/localhost

# Generate a self-signed certificate for testing
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/letsencrypt/live/localhost/selfsigned.key \
    -out /etc/letsencrypt/live/localhost/selfsigned.crt \
    -subj "/CN=localhost"

# Expose port 80
EXPOSE 80
EXPOSE 443

# Override the entrypoint to run your script
ENTRYPOINT ["/etc/nginx/entrypoint.sh"]
