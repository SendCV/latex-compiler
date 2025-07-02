BINARY := latex-compiler
TARGET := x86_64-unknown-linux-musl
COMMIT := $(shell git rev-parse --short HEAD)

.PHONY:
	@echo "No default target."

build:
	cargo zigbuild --target $(TARGET) --release -p $(BINARY)

build-image: build
	mkdir -p ./docker/tmp/
	cp ./target/$(TARGET)/release/$(BINARY) ./docker/tmp/$(BINARY)
	chmod +x ./docker/tmp/$(BINARY)
	docker build -t "sendcv_latex_compiler:latest" ./docker
	docker build -t "sendcv_latex_compiler:$(COMMIT)" ./docker

run: build-image
	docker run -p 3000:3000 sendcv_latex_compiler

stop:
	docker rm $(docker stop $(docker ps -a --filter ancestor=sendcv_latex_compiler --format="{{.ID}}"))

publish-image: build-image
	docker tag sendcv_latex_compiler:$(COMMIT) ghcr.io/sendcv/sendcv_latex_compiler:$(COMMIT)
	docker tag sendcv_latex_compiler:$(COMMIT) ghcr.io/sendcv/sendcv_latex_compiler:latest
	docker push ghcr.io/sendcv/sendcv_latex_compiler:$(COMMIT)
	docker push ghcr.io/sendcv/sendcv_latex_compiler:latest

current-tag:
	@echo $(COMMIT)
