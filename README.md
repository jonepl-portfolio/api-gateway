# Live Apps via Docker Swarms

1. Initial Docker Swarm

    ```bash
    $ docker swarm init
    ```

2. Create your network

    ```
    $ docker network create --driver overlay portfolio-network
    ```

3. Start you services

    ```
    # Ensure your images are available by building them or pulling them from OCI repo
    $ docker stack deploy -c csv-merger-api/docker-compose.yml -c web-portfolio/docker-compose.yml hosted-apps
    $ docker stack deploy -c api-gateway/docker-compose.yml hosted-apps
    ```

# Debugging

```sh
# Gets container information
$ docker ps

# Get service information
docker service ls

# View files within the container. Alternatively you can view this in docker desktop
docker exec -it <container_id> /bin/sh

# View all container details in JSON format
docker inspect <container_id_or_name>

# View logs of service. Alternatively you can view this in docker desktop if running locally
docker service logs <service_name>

```

## Debugging Volumes

```bash
## ~~~~~~~~ Inspect volume at server level ~~~~~~~~~
$ docker volume inspect {volume-name}

$ ls -R {Mountpoint-from-volume-inspect}

## ~~~~~~~~ Inspect volume at container level ~~~~~~~~~
# Create and ssh into a debugging container
$ docker run --rm -it -v {volume-name}:/container/path busybox sh

# Navigate to the desired container path
$ cd /container/path

# recursively list all directory and see if your contents is within
ls -R
```

Notes

* If you get a 502 bad gateway when requested data from a service connect to you api gateway, most likely your service is improperly configured. Check you nginx.conf file.

    ```md
    1. Ensure your service is on `docker service ls`
    2. Ensure your service has exposed the port you are trying to access from you api gateway
    3. Check `nginx.conf` to see if you server name is correctly. The name of the serviec should be value in services NOT the image name.
    ```

* You can use a service called busybox to debug if your network is discoverable or if service is reachable.

    ```sh
    docker run -it --rm --network <your_overlay_network> busybox sh
    wget -qO- http://<flask_service_name>:<flask_service_port>
    ```

Your dockerfile has to expose the port you are trying to connect to