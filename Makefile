dep: ## Download the dependencies.
	cd ./catgpt; pwd; ls -la; go mod download; ls -la;

build: dep ## Build catgpt executable.
	cd ./catgpt; mkdir -p ./bin; CGO_ENABLED=0 go build -o bin/; ls -la ./bin

docker-build: ## Build docker image
	docker build .
	docker image prune --force --filter label=stage=intermediate