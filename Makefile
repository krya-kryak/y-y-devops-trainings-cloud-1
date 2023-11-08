dep: ## Download the dependencies.
	go mod download

build: dep ## Build catgpt executable.
	mkdir -p ./bin


docker-build: ## Build docker image
	docker build .