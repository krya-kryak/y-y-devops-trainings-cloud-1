dep: ## Download the dependencies.
	cd ./catgpt
	pwd
	ls -la
	go mod download

build: dep ## Build catgpt executable.
	mkdir -p ./bin


docker-build: ## Build docker image
	docker build .