ifndef DOCKER_USERNAME
  ifneq (,$(wildcard .env))
    include .env
    export $(shell sed 's/=.*//' .env)
  endif

  ifndef DOCKER_USERNAME
    $(error DOCKER_USERNAME is not set. Please set it in the environment or in the .env file)
  endif
endif

# Creates local image
create-image:
	docker build -t $(DOCKER_USERNAME)/api-gateway:latest .
	docker image prune -f

build-image: create-image

# Creates local image verbose logs
create-image-verbose:
	docker build --progress=plain -t $(DOCKER_USERNAME)/api-gateway:latest .
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
