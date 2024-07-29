# Creates local image
create-image:
	docker build -t jonepl/api-gateway:latest .
	docker image prune -f

build-image: create-image

# Creates local image verbose logs
create-image-verbose:
	docker build --progress=plain -t jonepl/api-gateway:latest .
	docker image prune -f

# Starts local docker container
start-container:
	docker-compose up -d

# Stops local docker container
stop-container:
	docker-compose down

# Starts local docker stacks
start-service:
	docker stack deploy -c docker-compose.yml api-gateway

# Stops local docker stacks
remove-service:
	docker service rm $(shell docker service ls -f name=api --format "{{.ID}}")

remove-image:
	docker rm $(shell docker image ls --format "{{.ID}} {{.Repository}}" | grep 'api' | awk '{print $1}')
