# API Gateway

This repository contains the API Gateway for the hosted applications. The API Gateway is responsible for routing incoming requests to the appropriate microservice.


* [Design](#design)
* [Features](#features)
* [Prerequisites](#prerequisites)
* [Pre-Merge Checklist](#pre-merge-checklist)
* [Troubleshooting](#troubleshooting)


## Design

The API Gateway is designed to accept incoming requests and route them to the appropriate microservice. The gateway uses a reverse proxy to forward requests to the microservices.


## Features
Reverse proxy for routing incoming requests to microservices
Support for multiple microservices
Load balancing and scaling


## Prerequisites
* Docker
* Docker Swarm

## Pre-Merge Checklist
* Update [VERSION](./VERSION)
* Update [CHANGELOG.md](./CHANGELOG.md)


## Local Testing

Install bats
```
$ brew install bats
```

Running tests
```
make test
```

## Troubleshooting

### Basic Docker Swarm Debugging
Gets container information
```bash
$ docker ps
```

Check the API Gateway Logs
```bash
docker service logs api-gateway
```

Verify the Microservices are Running
```bash
docker service ls
```

Check the Network Configuration
```bash
docker network inspect api-gateway-network
```

View logs of service
```bash
docker service logs api-gateway
```


### Debugging Volumes
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