ifeq ($(OS),Windows_NT)
    CURRENT_DIR=$(CD)
	IMAGE_NAME := $(shell basename "$(CD)")
	SSH_PRIVATE_KEY="$$(type ~/.ssh/id_rsa)"
else
	CURRENT_DIR=$(PWD)
	IMAGE_NAME := $(shell basename "$(PWD)")
	SSH_PRIVATE_KEY="$$(cat ~/.ssh/id_rsa)"
endif

install:
	go env -w GOPRIVATE=github.com/erodriguezg
	go mod download

updatedeps:
	@echo Updating dependencies
	go get -d -v -u ./...

check:
	@echo Analyzing suspicious constructs
	go vet ./...

escape-analysis:
	@echo Analyzing the dynamic scope of pointers
	go build -gcflags='-m -l' -o bin/api cmd/main.go

build:
	go build -o bin/api cmd/main.go

compile:
	GO111MODULE=on \
	CGO_ENABLED=0 \
	GOOS=linux \
	GOARCH=amd64 \
	go build \
	-ldflags="-w -s" \
	-o bin/api ./cmd/main.go

run:
	go run cmd/main.go

test:
	go test ./...

linter:
	docker run --rm \
	-v ${CURRENT_DIR}:/app \
	-v ~/.ssh:/root/.ssh:ro \
	-w /app \
	golangci/golangci-lint:latest \
	/bin/bash -c "git config --global url."git@bitbucket.org:".insteadOf "https://bitbucket.org/" && golangci-lint run -v --timeout 3m" 

security:
	docker run --rm \
	-v ${CURRENT_DIR}:/app \
	-v ~/.ssh:/root/.ssh:ro \
	-w /app \
	--entrypoint="/bin/bash" \
	securego/gosec:latest -c "apk add -U --no-cache openssh && git config --global url."git@bitbucket.org:".insteadOf "https://bitbucket.org/" && gosec -exclude=G101 ./..."

test-all: compile test check security linter

docker-build:
	docker build \
	-f build/docker/dev/Dockerfile \
	--build-arg SSH_PRIVATE_KEY=$(SSH_PRIVATE_KEY) \
	-t aqmarket/${IMAGE_NAME}:local .

docker-run:
	docker run --rm -it -p 3000:3000 \
	-v ${CURRENT_DIR}/pkg:/go/src/bitbucket.org/aqmarketdev/${IMAGE_NAME}/pkg \
	--env-file ./.env \
	aqmarket/${IMAGE_NAME}:local

docker-drone-build: install compile
	docker build \
	-f build/docker/drone/Dockerfile \
	--build-arg SSH_PRIVATE_KEY=$(SSH_PRIVATE_KEY) \
	-t aqmarket/${IMAGE_NAME}:local-drone .

docker-drone-run:
	docker run --rm -it -p 3000:3000 \
	-v ${CURRENT_DIR}/pkg:/go/src/bitbucket.org/aqmarketdev/${IMAGE_NAME}/pkg \
	--env-file ./.env \
	aqmarket/${IMAGE_NAME}:local-drone
