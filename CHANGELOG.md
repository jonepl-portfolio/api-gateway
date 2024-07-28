# API Gateway Changelog

# 3.3.0
* Modify docker-compose.yml to consume Docker Secrets instead of using a .env file.

# 3.2.4
* Modify docker compose to make Portainer not secure 4.

# 3.2.3
* Modify docker compose to make Portainer not secure 3.

# 3.2.2
* Modify docker compose to make Portainer not secure 2.

# 3.2.1
* Modify docker compose to make Portainer not secure.

# 3.2.0
* Update docker compose in accordance to Portainer docs

## 3.1.3
* Add Portainer to subdomain.

## 3.1.2
* Update docker compose file to use .env volume instead of Docker Config.

## 3.1.1
* Add subdomain to nginx.template.conf.

## 3.1.0
* Add subdomain to nginx.template.conf.

## 3.0.2
* Update nginx conf for Portainer bugfix.

## 3.0.1
* Add Portainer maintenance app to http.

## 3.0.0
* Add Portainer maintenance app.

## 2.1.2
* Update nginx template & `.env` file to support dynamical certs for local development.

## 2.1.2
* Add Port 443 to Dockerfile.

## 2.1.1
* Fix docker compose entrypoint script to substitute DOMAIN in nginx conf template.

## 2.1.0
* Integrate SSL certificates into Nginx reverse proxy.

## 2.0.3
* Add Docker Compose validation and deployment steps to bitbucket pipeline.
* Fix Docker Compose volumes and Nginx template.

## 2.0.2
* Fixed the acme-challenge endpoint for Certbot.

## 2.0.1
* Remove certbot dependency.

## 2.0.0
* Add TLS certificates to nginx config.

## 1.0.1
* Update api gateway to depend on all services.

## 1.0.0
* Switch templated nginx configuration file with entrypoint script.

## 0.0.1
* Minor changes.

## 0.0.0
* Initial Commit.