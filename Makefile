IMAGE_NAME=smart_proxy_realm_ad_plugin:master
CONTAINER_NAME=smart_proxy_realm_ad_plugin-dev

# Default goal
.DEFAULT_GOAL := help

# Phony targets
.PHONY: help build default shell clean stop logs rebuild restart test

## Default target to build and run
default: build run

help: ## Diplay this help
	@echo "Usage: make [target]"
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build from Dockerfile
	docker build -t $(IMAGE_NAME) .

rebuild: ## Build without cache
	docker build -t $(IMAGE_NAME) --no-cache .

run: ## Run in the background
	docker inspect $(CONTAINER_NAME) >/dev/null 2>&1 && docker rm -f $(CONTAINER_NAME) || true
	docker run --name=$(CONTAINER_NAME) -v $(PWD):/app -d $(IMAGE_NAME) sleep infinity

shell: build run ## Open a shell in the running container
	docker exec -it $(CONTAINER_NAME) /bin/bash

stop: ## Stop the running container
	docker stop $(CONTAINER_NAME) || true

restart: stop run ## Restart the container

clean: ## clean
	docker rm -f $(CONTAINER_NAME) >> /dev/null 2>&1 || true
	docker rmi -f $(IMAGE_NAME) >> /dev/null 2>&1 || true

## Use inside the container

local-build: ## Inside Container: Build a local gem inside the container
	sudo gem build
	#sudo gem install radcli
	sudo gem install smart_proxy_realm_ad_plugin-0.1.gem
	sudo find /var/lib -name radcli*
	sudo find /var -name provider.rb
	sudo find /var -name realm*
	
