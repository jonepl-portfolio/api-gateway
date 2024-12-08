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

test:
	docker build -f tests/test.dockerfile -t api-gateway-test .
	
	# Restart the container if it is already running
	if docker ps --filter "name=api-gateway-test" --filter "status=running" | grep -q api-gateway-test; then \
		docker stop api-gateway-test && docker rm api-gateway-test; \
	elif docker ps -a --filter "name=api-gateway-test" | grep -q api-gateway-test; then \
		docker rm api-gateway-test; \
	fi

	# Create temp network
	docker network create portfolio-network

	# dummy mail server
	docker run -d --name mail-server  --network portfolio-network -p 3000:80 nginx

	# Start API gateway
	docker run -dp 8080:80 --name api-gateway-test --network portfolio-network -v $(shell pwd)/tests/test.env:/run/secrets/shared_secret api-gateway-test

	bats tests/test_api_gateway.bats

	docker stop api-gateway-test
	docker rm api-gateway-test
	docker rm -f mail-server
	docker network rm portfolio-network