# Use a specific version of the Nginx base image
FROM nginx:1.25.5

# Install bash
RUN apt-get update && apt-get install -y bash

# Copy the template nginx.conf to the container
COPY nginx.conf.template /etc/nginx/nginx.conf.template

# Create nginx configure form .env file (defaults to localhost)
COPY entrypoint.sh /etc/nginx/entrypoint.sh
RUN chmod +x /etc/nginx/entrypoint.sh

# Expose port 80
EXPOSE 80
EXPOSE 443
